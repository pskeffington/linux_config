#!/usr/bin/env bash
# Stage local user-level workspace and launchers after successful package installation.
# Does not enable radio PTT/TX, write to devices or autostart programs.
set -euo pipefail
preset="${1:-}"
case "$preset" in base|rf-receiver|field-comms) ;; *) echo 'Unknown preset' >&2; exit 2;; esac
[[ "$EUID" -ne 0 ]] || { echo 'Run as regular user' >&2; exit 2; }
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
workspace="$data_home/linux-config/workspaces/$preset"
cfg="$config_home/linux-config"
install -d -m 700 "$workspace" "$workspace/logs" "$workspace/fixtures" "$workspace/exports" "$cfg"
target="$cfg/active-preset.conf"
# Do not overwrite an operator-edited file; manual review is required.
if [[ -e "$target" ]]; then
  echo "EXISTS: $target (not overwritten)"
else
  printf 'PRESET=%s\nDEFAULT_RADIO_MODE=receive-only\nWORKSPACE=%s\n' "$preset" "$workspace" > "$target"
  chmod 600 "$target"
  echo "STAGED: $target"
fi
if [[ "$preset" != base ]]; then
  applications="$data_home/applications"
  install -d -m 755 "$applications"
  # Program launchers are inert until operator clicks; never auto-start.
  for item in 'gqrx:Gqrx SDR:gqrx' 'gnuradio-companion:GNU Radio Companion:gnuradio-companion'; do
    IFS=: read -r file title command <<< "$item"
    if command -v "$command" >/dev/null 2>&1; then
      entry="$applications/linux-config-$file.desktop"
      if [[ ! -e "$entry" ]]; then
        printf '[Desktop Entry]\nType=Application\nName=%s\nExec=%s\nTerminal=false\nCategories=Education;Science;\n' "$title" "$command" > "$entry"
        chmod 644 "$entry"
        echo "LAUNCHER: $entry"
      fi
    fi
  done
fi
if [[ "$preset" == field-comms ]]; then
  if command -v fldigi >/dev/null 2>&1; then
    entry="$data_home/applications/linux-config-fldigi.desktop"
    if [[ ! -e "$entry" ]]; then
      printf '[Desktop Entry]\nType=Application\nName=Fldigi (Manual Operator Launch)\nExec=fldigi\nTerminal=false\nCategories=Education;Science;\n' > "$entry"
      chmod 644 "$entry"
    fi
  fi
fi
echo 'Staging completed. Application defaults, radio frequency, CAT and transmit controls remain untouched.'
