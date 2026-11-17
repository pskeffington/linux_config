# Preconfigured Garuda deployments

## Design
One repository and one installer support three curated, intentionally limited profiles. Each profile selects checked-in **native package candidates**, leaves the existing Garuda look and feel untouched and disables scheduled automation by default. A preset is a *selection of software and safe user workspaces*, not working radio/device settings. Nothing transmits or autostarts.

| Preset | Packages | User-level result | Caveat |
|---|---|---|---|
| `base` | `core` | Private local config, fixtures, exports and logs directories | no radio apps |
| `rf-receiver` | `core,sdr` | Same, plus manual-launch shortcuts for available GNU Radio/GQRX | requires native package resolution and compatible SDR |
| `field-comms` | `core,sdr,ham,desktop` | Same, plus optional Fldigi shortcut | may install a larger desktop stack; review on non-KDE editions |

## Clone and plan (no modifications)
```bash
garuda-update
sudo pacman -S --needed git
git clone https://github.com/pskeffington/linux_config.git
cd linux_config
git switch scaffold/arch-rf-field-comms
bash scripts/garuda-preflight.sh
bash deploy.sh --plan --preset rf-receiver
```

## Deploy
```bash
bash deploy.sh --apply --preset rf-receiver
bash scripts/verify-deployment.sh rf-receiver
```

Use `--preset field-comms` for the larger workstation or `--preset base` for minimal tools. `--download` caches reviewed packages only; it does **not** stage user configuration or run apps. The installer calls `garuda-update` for an OS upgrade, then prompts via pacman and stages the user workspace only after all selected packages install. Missing candidate packages are a **blocked deployment**, not silently skipped.

## Safe staging details
`scripts/stage-preset.sh` creates `~/.local/share/linux-config/workspaces/<preset>/` with `logs`, `fixtures`, `exports`; creates `~/.config/linux-config/active-preset.conf` only when missing; and installs desktop launchers only when a matching binary is present. It neither overwrites the operator's existing active preset nor edits third-party SDR application configs. If active preset metadata already exists and differs, it logs `EXISTS` and requires manual reconciliation before claiming success.

No radio frequencies, PTT, repeater settings, CAT controls, antenna selection, LoRa region, GNSS coordinates, API credentials, machine serials, network endpoints or operator callsigns are copied into Git or written by presets.

## Acceptance stages
1. `python3 scripts/package-library.py validate --check` and `python3 -m unittest discover -s tests -v` in CI.
2. `bash deploy.sh --plan --preset <name>`: read-only resolution.
3. `bash deploy.sh --download --preset <name>`: cache packages after a full Garuda update.
4. `bash deploy.sh --apply --preset <name>`: verified native package install and safe user configuration staging.
5. `bash scripts/verify-deployment.sh <name>`: read-only application and workspace discovery.
6. Independent device/driver/SDR tests. No radio TX acceptance inferred.

## Recovery
System package transactions are handled by Garuda Update and pacman; use the supported Garuda Btrfs/snapshot recovery process if available. To remove only the user-level files, inspect `~/.config/linux-config`, `~/.local/share/linux-config` and launchers whose filenames begin `linux-config-`; **do not use a blind recursive deletion**. No service is enabled by a preset. Applications remain manually launched.
