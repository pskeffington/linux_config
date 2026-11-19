#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v pacman >/dev/null || { echo "ERROR: pacman is required (Arch/Garuda)." >&2; exit 2; }
for profile in core sdr ham; do
  printf '\n[%s]\n' "$profile"
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    if pacman -Qq "$pkg" >/dev/null 2>&1; then
      printf 'installed\t%s\n' "$pkg"
    elif pacman -Si "$pkg" >/dev/null 2>&1; then
      printf 'available\t%s\n' "$pkg"
    else
      printf 'UNRESOLVED\t%s\n' "$pkg"
    fi
  done < "$ROOT/packages/$profile.txt"
done
