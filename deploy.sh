#!/usr/bin/env bash
# Clone-and-deploy entrypoint. No AUR, transmit, firmware or kernel modifications.
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MODE=plan
PROFILES="core"
THEME=keep
AUTOMATION=off
ASSUME_YES=0
PRESET=''
PROFILES_EXPLICIT=0
THEME_EXPLICIT=0
AUTOMATION_EXPLICIT=0
usage() {
cat <<'USAGE'
Usage: bash deploy.sh [--plan|--download|--apply] [--preset base|rf-receiver|field-comms]\n                      [--profiles core,sdr,ham,desktop]
                      [--theme keep|breeze-dark|breeze-light]
                      [--automation off|inventory-weekly] [--yes]
Default: plan core only; no writes. Presets retain theme and automation defaults. --download caches packages, --apply installs.
--yes bypasses package confirmation only, not theme or driver safety gates.
No AUR, radio transmit, USB flashing, or system-wide services are configured.
USAGE
}
while (($#)); do
  case "$1" in
    --plan) MODE=plan;;
    --download) MODE=download;;
    --apply) MODE=apply;;
    --profiles) (($#>=2)) || { usage >&2; exit 2; }; PROFILES="$2"; PROFILES_EXPLICIT=1; shift;;
    --theme) (($#>=2)) || { usage >&2; exit 2; }; THEME="$2"; THEME_EXPLICIT=1; shift;;
    --automation) (($#>=2)) || { usage >&2; exit 2; }; AUTOMATION="$2"; AUTOMATION_EXPLICIT=1; shift;;
    --preset) (($#>=2)) || { usage >&2; exit 2; }; PRESET="$2"; shift;;
    --yes) ASSUME_YES=1;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2;;
  esac
  shift
done
if [[ -n "$PRESET" ]]; then
  case "$PRESET" in base|rf-receiver|field-comms) ;; *) echo "Unknown preset: $PRESET" >&2; exit 2;; esac
  file="$ROOT/presets/$PRESET.conf"
  [[ -r "$file" ]] || { echo "Preset missing: $file" >&2; exit 2; }
  preset_profiles='' preset_theme='' preset_automation='' preset_workspace=''
  while IFS='=' read -r key value || [[ -n "$key" ]]; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    case "$key" in
      PROFILES) preset_profiles="$value";;
      THEME) preset_theme="$value";;
      AUTOMATION) preset_automation="$value";;
      WORKSPACE) preset_workspace="$value";;
      *) echo "Invalid preset field: $key" >&2; exit 2;;
    esac
  done < "$file"
  [[ "$preset_workspace" == "$PRESET" ]] || { echo 'Preset identity mismatch' >&2; exit 2; }
  [[ -n "$preset_profiles" && -n "$preset_theme" && -n "$preset_automation" ]] || { echo 'Incomplete preset' >&2; exit 2; }
  ((PROFILES_EXPLICIT)) || PROFILES="$preset_profiles"
  ((THEME_EXPLICIT)) || THEME="$preset_theme"
  ((AUTOMATION_EXPLICIT)) || AUTOMATION="$preset_automation"
fi
[[ -r /etc/os-release ]] || { echo "Cannot detect OS." >&2; exit 2; }
# Detect actual package manager, not distro branding alone.
command -v pacman >/dev/null || { echo "Arch pacman required." >&2; exit 2; }
. /etc/os-release
[[ "${ID:-}" == "garuda" ]] || { echo "This deployment target is Garuda Linux; found ${ID:-unknown}." >&2; exit 2; }
command -v garuda-update >/dev/null || { echo "Garuda update tooling missing; use Garuda Toolbox repair before deploying." >&2; exit 2; }
[[ $EUID -ne 0 ]] || { echo "Run as regular user; sudo is invoked only for package operations." >&2; exit 2; }
case "$THEME" in keep|breeze-dark|breeze-light) ;; *) echo "Invalid theme" >&2; exit 2;; esac
case "$AUTOMATION" in off|inventory-weekly) ;; *) echo "Invalid automation" >&2; exit 2;; esac
IFS=, read -r -a selected <<< "$PROFILES"
(("${#selected[@]}">0)) || { echo "No profiles" >&2; exit 2; }
declare -A seen=()
packages=()
for profile in "${selected[@]}"; do
  case "$profile" in core|sdr|ham|desktop) ;; *) echo "Unknown profile: $profile" >&2; exit 2;; esac
  file="$ROOT/packages/$profile.txt"
  [[ -r "$file" ]] || { echo "Missing manifest: $file" >&2; exit 2; }
  while IFS= read -r candidate || [[ -n "$candidate" ]]; do
    candidate="${candidate%%#*}"
    candidate="${candidate//[$'\t\r ']/}"
    [[ -z "$candidate" ]] && continue
    [[ "$candidate" =~ ^[a-zA-Z0-9@._+-]+$ ]] || { echo "Invalid package identifier: $candidate" >&2; exit 2; }
    if [[ ! -v seen[$candidate] ]]; then
      seen[$candidate]=1
      packages+=("$candidate")
    fi
  done < "$file"
done
printf 'Mode: %s | Profiles: %s | Theme: %s | Automation: %s\n' "$MODE" "$PROFILES" "$THEME" "$AUTOMATION"
printf 'Resolved manifest entries: %s\n' "${#packages[@]}"
if [[ "$MODE" == plan ]]; then
  for pkg in "${packages[@]}"; do
    if pacman -Qq "$pkg" >/dev/null 2>&1; then
      printf 'INSTALLED %s\n' "$pkg"
    elif pacman -Si "$pkg" >/dev/null 2>&1; then
      printf 'AVAILABLE %s\n' "$pkg"
    else
      printf 'UNRESOLVED %s (repo metadata might be stale)\n' "$pkg"
    fi
  done
  echo 'Plan complete. No changes made.'
  exit 0
fi
# Avoid using -Sy in isolation (partial upgrades). Upgrades precede package resolution.
if [[ "$MODE" == apply ]]; then
  if ((ASSUME_YES==0)); then
    read -r -p 'Run full system upgrade and install resolved packages? [y/N] ' answer
    [[ "$answer" =~ ^[yY]$ ]] || { echo 'Aborted.'; exit 1; }
  fi
  echo "Running Garuda-supported full system update (interactive, without AUR)..." 
  garuda-update
else
  echo 'Download mode uses current sync databases; run garuda-update first to avoid partial upgrades.'
  if ((ASSUME_YES==0)); then
    read -r -p 'Download resolvable packages to pacman cache? [y/N] ' answer
    [[ "$answer" =~ ^[yY]$ ]] || { echo 'Aborted.'; exit 1; }
  fi
fi
available=()
unresolved=()
for pkg in "${packages[@]}"; do
  if pacman -Qq "$pkg" >/dev/null 2>&1; then
    printf 'INSTALLED %s\n' "$pkg"
  elif pacman -Si "$pkg" >/dev/null 2>&1; then
    available+=("$pkg")
  else
    unresolved+=("$pkg")
    printf 'UNRESOLVED %s\n' "$pkg" >&2
  fi
done
if (("${#unresolved[@]}" > 0)); then
  printf 'Unresolved manifest entries: %s. Refusing partial deployment.\n' "${unresolved[*]}" >&2
  exit 3
fi
if (("${#available[@]}" > 0)); then
  if [[ "$MODE" == download ]]; then
    sudo pacman -Sw --needed -- "${available[@]}"
  else
    sudo pacman -S --needed -- "${available[@]}"
  fi
fi
if [[ "$MODE" == apply ]]; then
  [[ "$THEME" == keep ]] || bash "$ROOT/scripts/apply-theme.sh" "$THEME"
  [[ "$AUTOMATION" == off ]] || bash "$ROOT/scripts/configure-automation.sh" "$AUTOMATION"
  [[ -z "$PRESET" ]] || bash "$ROOT/scripts/stage-preset.sh" "$PRESET"
fi
echo "$MODE completed. Review unresolved hardware acceptance gates in docs/ARCHITECTURE.md."
