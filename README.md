# linux_config

Reproducible Arch Linux / Garuda workstation configuration for RF field communications, SDR and amateur radio, with optional KDE desktop theme and read-only scheduled inventory.

## Fresh Garuda: clone and deploy

```bash
sudo pacman -Syu --needed git
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
