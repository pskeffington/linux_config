#!/usr/bin/env bash
# Read-only Garuda-specific desktop, storage, tooling and package preflight.
set -euo pipefail
[[ -r /etc/os-release ]] || { echo 'Missing /etc/os-release' >&2; exit 2; }
. /etc/os-release
[[ "${ID:-}" == garuda ]] || { echo "Unsupported distro: ${ID:-unknown}; requires Garuda." >&2; exit 2; }
command -v pacman >/dev/null || { echo 'Missing pacman' >&2; exit 2; }
command -v garuda-update >/dev/null || { echo 'Missing garuda-update; repair through Garuda Toolbox' >&2; exit 2; }
printf 'Garuda release: %s\n' "${PRETTY_NAME:-Garuda Linux}"
printf 'Architecture: %s\n' "$(uname -m)"
printf 'Kernel: %s\n' "$(uname -r)"
printf 'Desktop: %s\n' "${XDG_CURRENT_DESKTOP:-not set}"
printf 'Session: %s\n' "${XDG_SESSION_TYPE:-not set}"
printf 'Update tool: %s\n' "$(command -v garuda-update)"
printf 'Package manager: %s\n' "$(command -v pacman)"
printf 'Root filesystem: '
if command -v findmnt >/dev/null; then
  findmnt -n -o FSTYPE / || true
else
  echo 'unknown'
fi
for tool in garuda-health snapper btrfs-assistant lookandfeeltool plasma-apply-colorscheme; do
  if command -v "$tool" >/dev/null; then printf 'AVAILABLE %s\n' "$tool"; else printf 'MISSING_OR_OPTIONAL %s\n' "$tool"; fi
done
echo 'Configured sync repositories (not proof of package availability):'
pacman-conf --repo-list 2>/dev/null || echo 'pacman-conf unavailable'
echo 'Preflight is read-only. Do not run automatic repairs, modify kernel, or change Plasma theme.'
