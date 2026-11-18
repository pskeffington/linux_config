#!/bin/sh
set -eu

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/cpu-temp-monitor"
log_file="$log_dir/temperature.csv"
interval="${CPU_TEMP_MONITOR_INTERVAL:-10}"
max_bytes=5242880
keep=4
header='timestamp,cpu_package_c,cpu_core0_c,cpu_core1_c,cpu_core2_c,cpu_core3_c,scaling_cur_freq_khz,scaling_max_freq_khz,core0_throttle_count,core1_throttle_count,core2_throttle_count,core3_throttle_count,package_throttle_count,core0_throttle_max_time_ms,core1_throttle_max_time_ms,core2_throttle_max_time_ms,core3_throttle_max_time_ms,package_throttle_max_time_ms,core0_throttle_total_time_ms,core1_throttle_total_time_ms,core2_throttle_total_time_ms,core3_throttle_total_time_ms,package_throttle_total_time_ms,cpu_busy_pct,load1'

mkdir -p "$log_dir"

read_hwmon() {
    kind=$1
    wanted_label=$2
    for name_file in /sys/class/hwmon/hwmon*/name; do
        [ -r "$name_file" ] || continue
        [ "$(cat "$name_file")" = "$kind" ] || continue
        dir=${name_file%/name}
        for input in "$dir"/temp*_input; do
            [ -r "$input" ] || continue
            label_file=${input%_input}_label
            [ -r "$label_file" ] || continue
            [ "$(cat "$label_file")" = "$wanted_label" ] || continue
            value=$(cat "$input")
            awk -v v="$value" 'BEGIN { printf "%.1f", v / 1000 }'
            return
        done
    done
    printf ''
}

read_count() {
    path=$1
    if [ -r "$path" ]; then cat "$path"; else printf ''; fi
}

rotate_log() {
    [ -f "$log_file" ] || return 0
    force=${1:-no}
    bytes=$(wc -c < "$log_file")
    if [ "$force" != force ] && [ "$bytes" -lt "$max_bytes" ]; then return 0; fi
    n=$keep
    while [ "$n" -gt 1 ]; do
        previous=$((n - 1))
        [ ! -f "$log_file.$previous" ] || mv -f "$log_file.$previous" "$log_file.$n"
        n=$previous
    done
    mv -f "$log_file" "$log_file.1"
}

write_header_if_needed() {
    if [ -s "$log_file" ]; then
        old_header=$(head -n 1 "$log_file")
        [ "$old_header" = "$header" ] && return 0
        rotate_log force
    fi
    printf '%s\n' "$header" > "$log_file"
}

previous_total=
previous_idle=
write_header_if_needed

while :; do
    rotate_log
    write_header_if_needed
    timestamp=$(date --iso-8601=seconds)
    package=$(read_hwmon coretemp 'Package id 0')
    core0=$(read_hwmon coretemp 'Core 0')
    core1=$(read_hwmon coretemp 'Core 1')
    core2=$(read_hwmon coretemp 'Core 2')
    core3=$(read_hwmon coretemp 'Core 3')
    current=$(read_count /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    maximum=$(read_count /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
    throttle_values=$(awk '{ printf "%s%s", NR == 1 ? "" : " ", $0 }' \
        /sys/devices/system/cpu/cpu0/thermal_throttle/core_throttle_count \
        /sys/devices/system/cpu/cpu1/thermal_throttle/core_throttle_count \
        /sys/devices/system/cpu/cpu2/thermal_throttle/core_throttle_count \
        /sys/devices/system/cpu/cpu3/thermal_throttle/core_throttle_count \
        /sys/devices/system/cpu/cpu0/thermal_throttle/package_throttle_count \
        /sys/devices/system/cpu/cpu0/thermal_throttle/core_throttle_max_time_ms \
        /sys/devices/system/cpu/cpu1/thermal_throttle/core_throttle_max_time_ms \
        /sys/devices/system/cpu/cpu2/thermal_throttle/core_throttle_max_time_ms \
        /sys/devices/system/cpu/cpu3/thermal_throttle/core_throttle_max_time_ms \
        /sys/devices/system/cpu/cpu0/thermal_throttle/package_throttle_max_time_ms \
        /sys/devices/system/cpu/cpu0/thermal_throttle/core_throttle_total_time_ms \
        /sys/devices/system/cpu/cpu1/thermal_throttle/core_throttle_total_time_ms \
        /sys/devices/system/cpu/cpu2/thermal_throttle/core_throttle_total_time_ms \
        /sys/devices/system/cpu/cpu3/thermal_throttle/core_throttle_total_time_ms \
        /sys/devices/system/cpu/cpu0/thermal_throttle/package_throttle_total_time_ms)
    set -- $throttle_values
    core0_count=$1; core1_count=$2; core2_count=$3; core3_count=$4; package_count=$5
    core0_max=$6; core1_max=$7; core2_max=$8; core3_max=$9
    shift 9
    package_max=$1; core0_total=$2; core1_total=$3; core2_total=$4; core3_total=$5; package_total=$6
    counters=$(awk '/^cpu / { total=0; for (i=2; i<=NF; i++) total += $i; if (NF >= 10) total -= $10; if (NF >= 11) total -= $11; idle=$5+$6; printf "%.0f %.0f", total, idle; exit }' /proc/stat)
    total=${counters%% *}
    idle=${counters#* }
    busy=
    if [ -n "$previous_total" ] && [ "$total" -gt "$previous_total" ]; then
        busy=$(awk -v t="$total" -v pt="$previous_total" -v i="$idle" -v pi="$previous_idle" 'BEGIN { printf "%.1f", 100 * ((t - pt) - (i - pi)) / (t - pt) }')
    fi
    previous_total=$total
    previous_idle=$idle
    load1=$(awk '{ print $1 }' /proc/loadavg)
    printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
        "$timestamp" "$package" "$core0" "$core1" "$core2" "$core3" \
        "$current" "$maximum" "$core0_count" "$core1_count" "$core2_count" "$core3_count" "$package_count" \
        "$core0_max" "$core1_max" "$core2_max" "$core3_max" "$package_max" \
        "$core0_total" "$core1_total" "$core2_total" "$core3_total" "$package_total" "$busy" "$load1" >> "$log_file"
    sleep "$interval"
done
