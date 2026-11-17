#!/usr/bin/env bash
# Read-only host resolution report: package availability is host- and date-specific.
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
command -v pacman >/dev/null || { echo 'Requires Arch/Garuda pacman' >&2; exit 2; }
command -v python >/dev/null || { echo 'Install python or run core profile first' >&2; exit 2; }
python "$ROOT/scripts/package-library.py" validate --check
printf 'package\tprofile\tstatus\tversion\n'
for profile in core sdr ham desktop; do
  while IFS= read -r name || [[ -n "$name" ]]; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if pacman -Qq "$name" >/dev/null 2>&1; then
      version="$(pacman -Q "$name" 2>/dev/null | awk '{print $2}')"
      printf '%s\t%s\tINSTALLED\t%s\n' "$name" "$profile" "$version"
    elif pacman -Si "$name" >/dev/null 2>&1; then
      version="$(pacman -Si "$name" 2>/dev/null | awk '/^Version/{print $3; exit}')"
      printf '%s\t%s\tAVAILABLE\t%s\n' "$name" "$profile" "$version"
    else
      printf '%s\t%s\tUNRESOLVED\t-\n' "$name" "$profile"
    fi
  done < "$ROOT/packages/$profile.txt"
done
