# Clone, inspect, deploy

## Supported target
Fresh Garuda / Arch Linux, pacman, standard non-root account. KDE Plasma theming is optional and applied only in a live KDE session. Running from other distributions is unsupported.

## Deployment contract
1. Install git with `sudo pacman -Syu --needed git`.
2. Clone `https://github.com/pskeffington/linux_config.git`.
3. Until PR #1 is merged, switch to `scaffold/arch-rf-field-comms`.
4. Run `bash deploy.sh --plan --profiles core,sdr,ham`.
5. Run `bash deploy.sh --download --profiles core,sdr,ham` to cache available native packages, or `bash deploy.sh --apply --profiles core,sdr,ham` to fully update and install.
6. Optional desktop: `bash deploy.sh --apply --profiles core,desktop --theme breeze-dark --automation inventory-weekly`.
7. Use `bash scripts/inventory-rf.sh` to collect non-root evidence; review private evidence locally.

Default plan performs no writes. Download and apply never resolve or install AUR packages. Unresolved package identifiers cause a non-zero exit before package installation (after system upgrade in apply mode). Do not assume availability of every candidate in all Arch derivatives; update package manifests with verified identifiers if required. Only apply touches theme/timer, and both are opt-in.

## Theme and desktop
Do not replace Garuda desktop design by default. `keep` preserves the present theme. KDE Breeze-dark or Breeze-light needs a KDE session with lookandfeeltool. Original kdeglobals is backed up. No login manager, boot theme, bootloader, shell dotfile or compositor modification is included.

## Automation
The only initial automation is weekly read-only hardware inventory via a systemd **user** timer. It is not enabled in default deployment. No monitoring services or SDR network ports are opened. Disable with `systemctl --user disable --now linux-config-rf-inventory.timer`; remove unit files if no longer needed.

## Idempotency and failure gates
- Native packages use pacman --needed and installation manifests are deduplicated.
- Full system upgrade comes before installation; no silent AUR helpers.
- Apply refuses unresolved package identifiers to avoid inadvertently incomplete profiles.
- Theme only applies to matching live KDE environments.
- Evidence never enters Git by default.
- Offline repository authorship is not hardware validation; verify with `bash -n deploy.sh scripts/*.sh` and then run on target Garuda.
- No PTT, transmit presets, driver blacklisting, firmware flashes or udev privilege escalation.
