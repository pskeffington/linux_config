#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
profile="${1:-}"
case "$profile" in core|sdr|ham) ;; *) echo "Usage: bash scripts/install-profile.sh {core|sdr|ham}" >&2; exit 2;; esac
command -v pacman >/dev/null || { echo "Requires Arch/Garuda with pacman" >&2; exit 2; }
pkgs=()
while IFS= read -r pkg || [[ -n "$pkg" ]]; do
  [[ -z "$pkg" || "$pkg" == \#* ]] && continue
  if pacman -Qq "$pkg" >/dev/null 2>&1; then
    printf 'Already installed: %s\n' "$pkg"
  elif pacman -Si "$pkg" >/dev/null 2>&1; then
    pkgs+=("$pkg")
  else
    printf 'SKIP unresolved native package: %s (review AUR/upstream separately)\n' "$pkg" >&2
  fi
done < "$ROOT/packages/$profile.txt"
if (("${#pkgs[@]}" == 0)); then echo "Nothing to install."; exit 0; fi
printf 'Proposed native packages: %s\n' "${pkgs[*]}"
read -r -p 'Install with sudo pacman -S --needed? [y/N] ' confirm
[[ "$confirm" == [yY] ]] || { echo "Aborted."; exit 1; }
sudo pacman -S --needed -- "${pkgs[@]}"
