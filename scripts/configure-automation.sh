#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
case "${1:-}" in inventory-weekly) ;; *) echo 'Usage: bash scripts/configure-automation.sh inventory-weekly' >&2; exit 2;; esac
[[ $EUID -ne 0 ]] || { echo 'Do not run as root' >&2; exit 2; }
command -v systemctl >/dev/null || { echo 'systemd unavailable' >&2; exit 3; }
[[ "$ROOT" != *$'\n'* ]] || { echo 'Repository path contains newline' >&2; exit 3; }
[[ -f "$ROOT/scripts/inventory-rf.sh" ]] || exit 3
install -d -m 700 "$HOME/.config/systemd/user"
unitdir="$HOME/.config/systemd/user"
# Quote systemd path arguments with % escaping; avoid shell injection by no sh -c.
escaped="${ROOT//%/%%}"
cat > "$unitdir/linux-config-rf-inventory.service" <<UNIT
[Unit]
Description=Receive-only RF device inventory (local private evidence)
[Service]
Type=oneshot
ExecStart=/usr/bin/bash "$escaped/scripts/inventory-rf.sh"
UNIT
cat > "$unitdir/linux-config-rf-inventory.timer" <<'UNIT'
[Unit]
Description=Weekly RF hardware inventory
[Timer]
OnCalendar=weekly
Persistent=true
[Install]
WantedBy=timers.target
UNIT
systemctl --user daemon-reload
systemctl --user enable --now linux-config-rf-inventory.timer
echo 'Weekly user timer enabled. Evidence stays in repository-local ignored evidence/.'
