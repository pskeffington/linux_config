# linux_config

Reproducible Arch Linux / Garuda workstation configuration for RF field communications, SDR and amateur radio, with optional KDE desktop theme and read-only scheduled inventory.

## Fresh Garuda: clone and deploy

```bash
garuda-update
sudo pacman -S --needed git
git clone https://github.com/pskeffington/linux_config.git
cd linux_config
git switch scaffold/arch-rf-field-comms
bash deploy.sh --plan --profiles core,sdr,ham,desktop
bash deploy.sh --apply --profiles core,sdr,ham,desktop
```

**The branch switch is temporary until [PR #1](https://github.com/pskeffington/linux_config/pull/1) is merged.** After merging, `git clone` and `bash deploy.sh --apply ...` are sufficient. A fresh machine needs `git` and access to pacman repositories.

Optional package download without installation:

```bash
bash deploy.sh --download --profiles core,sdr,ham,desktop
```

Opt-in KDE theme and local weekly read-only inventory:

```bash
bash deploy.sh --apply --profiles core,desktop --theme breeze-dark --automation inventory-weekly
```

The default is `bash deploy.sh`: read-only plan mode, core only. The `--apply` path requests confirmation, upgrades the system, rejects unresolved native packages, and installs available packages. It does not automatically use an AUR helper or change the desktop unless requested. Review candidate package lists for your particular Arch/Garuda distribution.

## Architecture and handoff

- [Detailed installation and rollback notes](docs/DEPLOYMENT.md)
- [RF architecture and acceptance stages](docs/ARCHITECTURE.md)
- [Codex instructions](docs/AGENTS.md)
- [Source-linked operator literature matrix](literature/RF_FIELD_COMMS_MATRIX.tsv)
- [Native candidate manifests](packages/)
- [Separate AUR review queue](packages/aur-review.tsv)
- [Static syntax and manifest test](tests/static.sh)

Run `bash tests/static.sh` for a local no-install syntax/manifest check. Physical acceptance, package availability, theme integration, and timer operation require validation on the target workstation. RF transmission is outside this deployment.

## Master package library
The [canonical package registry](packages/master-catalog.json) holds 33 native pacman candidates and six manual-review packages. [Documentation](docs/MASTER_PACKAGE_LIBRARY.md) and [schema](packages/master-catalog.schema.json) define statuses and safety. Keep manifests synchronized with:
```bash
python scripts/package-library.py validate --check
python scripts/package-library.py summary
```
On a configured Arch/Garuda workstation, `bash scripts/resolve-package-library.sh` checks repository/installed package availability read-only. Candidate status is **not** proof of package availability. The existing `deploy.sh` continues to use checked-in profile manifests. CI and manual host acceptance must pass before release.

### Garuda alignment
Follow [Garuda-specific setup, preflight, desktop preservation and recovery guidance](docs/GARUDA_INSTALL_ALIGNMENT.md). The installer now runs `garuda-update` for full upgrades; it does not silently update AUR packages, replace Garuda's default theme, or change kernel/boot settings.

## Preconfigured Garuda deployment
Use a preset for a ready-to-launch **receive-only** workstation without manually selecting packages:
```bash
bash deploy.sh --plan --preset rf-receiver
bash deploy.sh --apply --preset rf-receiver
bash scripts/verify-deployment.sh rf-receiver
```
Presets: `base` (core utilities), `rf-receiver` (core + SDR) and `field-comms` (core + SDR + ham + desktop). Each preserves Garuda's theme, disables user automations and never configures a transmitter. Deployment stages private user-level folders and manual-launch desktop entries only after successful installation. See [preconfigured deployment guide](docs/PRECONFIGURED_DEPLOYMENT.md). Software/driver availability and device hardware still require verification on the actual host.
