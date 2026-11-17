#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/evidence"
mkdir -p "$DEST"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
out="$DEST/host-$stamp.txt"
{
  printf 'timestamp_utc=%s\n' "$stamp"
  printf '\n--- OS ---\n'
  cat /etc/os-release 2>/dev/null || true
  uname -a
  printf '\n--- USB ---\n'
  command -v lsusb >/dev/null && lsusb || echo 'lsusb unavailable'
  printf '\n--- PCI ---\n'
  command -v lspci >/dev/null && lspci -nn || echo 'lspci unavailable'
  printf '\n--- Kernel SDR/serial modules ---\n'
  lsmod | grep -Ei 'rtl|dvb|hackrf|usbserial|cp210|ch34|ftdi' || true
  printf '\n--- Device paths ---\n'
  find /dev/serial -maxdepth 3 -type l -print 2>/dev/null || true
  printf '\n--- Installed candidate packages ---\n'
  pacman -Qq 2>/dev/null | grep -Ei 'rtl|soapy|gnuradio|gqrx|hamlib|fldigi|direwolf|hackrf|meshtastic' || true
} > "$out"
chmod 600 "$out"
sha256sum "$out" > "$out.sha256"
chmod 600 "$out.sha256"
echo "Local inventory: $out"
echo "Do not commit this file; host identifiers may be sensitive."
