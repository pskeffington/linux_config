# Garuda-specific acceptance and deployment

## Confirmed Garuda policy
**Use `garuda-update` for full system upgrades, not bare `sudo pacman -Syu`.** Garuda Update includes mirror/keyring and known-conflict handling, Garuda Health checks and Btrfs free-space/snapshot awareness. Run as the normal user (it asks for privilege as needed). See:
- https://wiki.garudalinux.org/en/maintenance/garuda-update/
- https://wiki.garudalinux.org/en/installation/post-installation-tasks/
- https://wiki.garudalinux.org/en/garuda-apps/garuda-health/
- https://wiki.garudalinux.org/en/maintenance/aur-packages/

AUR updates are **not part of the deployment**. Chaotic-AUR is an enabled pacman repository in typical Garuda installs; its prebuilt packages are not the same trust model as Arch official packages. The master catalog's `pacman-sync-database` designation means **configured pacman repos**, not necessarily official Arch. Resolve package origin before approving it.

## First boot
1. Complete Garuda's Setup Assistant and first full update. If not completed, run `garuda-update` and resolve any reported critical health issues before deployment.
2. Open terminal as the regular desktop user and install Git if absent: `sudo pacman -S --needed git` (after the full Garuda update).
3. Clone repository and checkout the review branch until merged.
4. `bash scripts/garuda-preflight.sh` prints OS, architecture, kernel, desktop, current sync repo list and optional utilities. It makes no changes.
5. `python scripts/package-library.py validate --check` requires Python; use Git-only bootstrap and choose core profile if Python is absent.
6. `bash deploy.sh --plan --profiles core,sdr,ham,desktop` prints package availability without changes.
7. `bash deploy.sh --download --profiles core,sdr,ham,desktop` caches packages from current sync databases; run `garuda-update` first.
8. `bash deploy.sh --apply --profiles core,sdr,ham,desktop` performs Garuda Update followed by reviewed pacman install. Read prompts, conflict notices, space warnings and reboot notices; no automatic `--noconfirm`.
9. `bash scripts/inventory-rf.sh` captures optional local evidence. Do not commit serial IDs, IP addresses, account details or raw IQ.

## KDE and other editions
Keep theme unchanged by default, especially Dr460nized and Mokka. Optional Breeze themes are explicitly requested, session-scoped, and require installed KDE theme tools. Hyprland/Sway/Xfce may have entirely different theme stacks; do not invoke KDE commands on them. Do not overwrite Garuda shell startup, login manager, bootloader, dracut configuration, firmware or kernel.

## Snapshot and recovery
Garuda often provides Btrfs snapshots and Snapper; do not assume the root filesystem is Btrfs or that Snapper works until detected. `garuda-health` is read-only unless `--fix` is passed. Do not run automatic `garuda-update remote reset-snapper`, which can delete snapshots. Restore actions require deliberate operator interaction using Garuda's supported tools.

## Acceptance outstanding
Host-based package origins, versions, available repo names, native driver support and installation compatibility remain unverified. CI static checks cannot substitute for Garuda physical acceptance. Record observed host evidence and exact hardware ID before promoting candidates to HOST_PASS/HARDWARE_PASS.
