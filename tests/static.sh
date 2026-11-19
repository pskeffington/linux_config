#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
for script in "$ROOT/deploy.sh" "$ROOT"/scripts/*.sh; do
  bash -n "$script"
  printf 'BASH_SYNTAX_OK %s\n' "${script#"$ROOT/"}"
done
for manifest in "$ROOT"/packages/*.txt; do
  while IFS= read -r item || [[ -n "$item" ]]; do
    item="${item%%#*}"; item="${item//[$'\t\r ']/}"
    [[ -z "$item" || "$item" =~ ^[a-zA-Z0-9@._+-]+$ ]] || { echo "Invalid item in $manifest" >&2; exit 1; }
  done < "$manifest"
done
echo 'Static validation complete (no packages installed).'
