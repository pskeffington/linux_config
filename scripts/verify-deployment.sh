#!/usr/bin/env bash
# Read-only checks of deployment prerequisites and staged workspace.
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
preset="${1:-base}"
case "$preset" in base|rf-receiver|field-comms) ;; *) echo 'Usage: bash scripts/verify-deployment.sh {base|rf-receiver|field-comms}' >&2; exit 2;; esac
bash "$ROOT/scripts/garuda-preflight.sh"
echo '--- Read-only RF adapter inventory (not receive acceptance) ---'
bash "$ROOT/scripts/verify-rf-adapters.sh"
echo '--- Installed application checks (not hardware acceptance) ---'
for exe in git python gqrx gnuradio-companion rtl_test fldigi direwolf; do
  if command -v "$exe" >/dev/null 2>&1; then
    echo "PRESENT $exe"
  else
    echo "NOT_PRESENT $exe"
  fi
done
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
[[ -f "$config_home/linux-config/active-preset.conf" ]] && echo 'PRESET_METADATA_PRESENT' || echo 'PRESET_METADATA_MISSING'
[[ -d "$data_home/linux-config/workspaces/$preset" ]] && echo 'WORKSPACE_PRESENT' || echo 'WORKSPACE_MISSING'
echo 'Application presence is not a passing RF test. Hardware and UI validation remain separate.'
