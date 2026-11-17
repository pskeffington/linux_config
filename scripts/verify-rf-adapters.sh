#!/usr/bin/env bash
# Read-only adapter discovery. Does not open devices, probe networks, tune, or transmit.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MATRIX="$ROOT/hardware/ADAPTER_MATRIX.tsv"
[[ -r "$MATRIX" ]] || { echo "Missing adapter matrix: $MATRIX" >&2; exit 2; }

printf 'Adapter matrix: %s\n' "$MATRIX"
printf 'Observed at UTC: %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo 'Scope: local USB sysfs IDs, bound kernel driver, installed packages and tool presence only.'
echo 'No serial numbers, TTY opens, SDR API calls, network discovery, firmware actions, tuning or transmission.'

echo '--- Matching attached USB adapters (example IDs only) ---'
matches=0
for device in /sys/bus/usb/devices/*; do
  [[ -r "$device/idVendor" && -r "$device/idProduct" ]] || continue
  IFS= read -r vendor < "$device/idVendor"
  IFS= read -r product < "$device/idProduct"
  family=''
  case "${vendor,,}:${product,,}" in
    1d50:60a1) family='Airspy family (example ID)';;
    1d50:6089) family='HackRF family (example ID)';;
    1df7:2500) family='Mirics MSi2500 bridge (not exact SDRplay model)';;
    1a86:7523) family='CH34x serial family (example ID)';;
    10c4:ea60) family='CP210x serial family (example ID)';;
    0403:6001) family='FTDI serial family (example ID)';;
    *) continue;;
  esac
  drivers=()
  for interface in "$device":*; do
    [[ -L "$interface/driver" ]] || continue
    drivers+=("$(basename -- "$(readlink -- "$interface/driver")")")
  done
  if ((${#drivers[@]})); then
    driver="$(IFS=,; printf '%s' "${drivers[*]}")"
  else
    driver='unbound-or-not-exposed'
  fi
  printf 'USB_MATCH family=%s id=%s:%s driver=%s\n' "$family" "${vendor,,}" "${product,,}" "$driver"
  matches=$((matches + 1))
done
((matches > 0)) || echo 'NO_MATCHING_USB_ID: no example adapter IDs found; this does not establish absence of network or unlisted hardware.'

echo '--- Installed native userspace packages ---'
if command -v pacman >/dev/null 2>&1; then
  for package in airspy hackrf libuhd libuhd-utils; do
    if pacman -Q "$package" 2>/dev/null; then
      :
    else
      printf 'NOT_INSTALLED %s\n' "$package"
    fi
  done
else
  echo 'PACMAN_UNAVAILABLE: package state not checked.'
fi

echo '--- Discovery utility presence (utilities are not executed) ---'
for tool in airspy_info hackrf_info uhd_find_devices uhd_usrp_probe; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'AVAILABLE_TOOL %s\n' "$tool"
  else
    printf 'MISSING_TOOL %s\n' "$tool"
  fi
done

echo '--- Acceptance boundary ---'
echo 'This report is inventory evidence only. It does not prove driver functionality, IQ capture, or receive performance.'
echo 'SDRplay vendor API, Ethernet USRP discovery and all serial-port behavior require separate operator-led review.'
