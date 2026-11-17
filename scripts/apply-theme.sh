#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  keep) echo "Theme unchanged"; exit 0;;
  breeze-dark) theme='org.kde.breezedark.desktop'; scheme='BreezeDark';;
  breeze-light) theme='org.kde.breeze.desktop'; scheme='BreezeLight';;
  *) echo 'Usage: bash scripts/apply-theme.sh {keep|breeze-dark|breeze-light}' >&2; exit 2;;
esac
[[ $EUID -ne 0 ]] || { echo 'Do not run as root' >&2; exit 2; }
command -v lookandfeeltool >/dev/null || { echo 'KDE Plasma lookandfeeltool unavailable; theme skipped' >&2; exit 3; }
[[ -n "${XDG_CURRENT_DESKTOP:-}" && "${XDG_CURRENT_DESKTOP,,}" == *kde* ]] || {
  echo 'Current desktop is not KDE. Refusing theme changes.' >&2
  exit 3
}
# Check requested Look-and-Feel name is installed before editing preferences.
if ! lookandfeeltool --list 2>/dev/null | grep -Fxq "$theme"; then
  echo "Missing KDE theme $theme; refusing." >&2; exit 3
fi
mkdir -p "$HOME/.config"
if [[ -f "$HOME/.config/kdeglobals" ]]; then
  cp -p "$HOME/.config/kdeglobals" "$HOME/.config/kdeglobals.linux-config.bak"
fi
lookandfeeltool --apply "$theme"
if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
  plasma-apply-colorscheme "$scheme"
fi
echo "Applied $theme. Restart session if not all elements refresh."
