# linux_config

Arch Linux / Garuda configuration workbench for modular RF field communications, SDR, amateur radio, and receive-only hardware acceptance.

## Start on a fresh Garuda workstation

```bash
sudo pacman -Syu --needed git
git clone https://github.com/pskeffington/linux_config.git
cd linux_config
git switch scaffold/arch-rf-field-comms
bash scripts/check-packages.sh
bash scripts/inventory-rf.sh
bash scripts/install-profile.sh core
```

For SDR or ham package groups, use `bash scripts/install-profile.sh sdr` or `bash scripts/install-profile.sh ham` after reviewing `packages/*.txt`. The scripts check availability and request confirmation; no AUR packages are installed automatically.

## Repository navigation
- [Architecture and phase gates](docs/ARCHITECTURE.md)
- [Codex agent handoff](docs/AGENTS.md)
- [Literature and operator reference matrix](literature/RF_FIELD_COMMS_MATRIX.tsv)
- [Core package candidates](packages/core.txt)
- [SDR package candidates](packages/sdr.txt)
- [Amateur radio candidates](packages/ham.txt)
- [AUR manual review queue](packages/aur-review.tsv)

**Current stage:** first-pass scaffold only. Not installed or verified against physical equipment. Package names and upstream references require on-device validation before declaring acceptance. TX/PTT is disabled by policy; only explicit authorized work may add transmit actions.
