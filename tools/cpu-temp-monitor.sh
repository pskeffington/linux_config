#!/bin/sh
set -eu

log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/cpu-temp-monitor"
log_file="$log_dir/temperature.csv"
interval="${CPU_TEMP_MONITOR_INTERVAL:-10}"
max_bytes=5242880
keep=4

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
    bytes=$(wc -c < "$log_file")
    [ "$bytes" -lt "$max_bytes" ] && return 0
    n=$keep
    while [ "$n" -gt 1 ]; do
        previous=$((n - 1))
        [ ! -f "$log_file.$previous" ] || mv -f "$log_file.$previous" "$log_file.$n"
        n=$previous
    done
    mv -f "$log_file" "$log_file.1"
}

write_header_if_needed() {
    [ -s "$log_file" ] && return 0
    printf 'timestamp,cpu_package_c,cpu_core0_c,cpu_core1_c,cpu_core2_c,cpu_core3_c,scaling_cur_freq_khz,scaling_max_freq_khz,core_throttle_count,package_throttle_count\n' > "$log_file"
}

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
    core_throttle=$(read_count /sys/devices/system/cpu/cpu0/thermal_throttle/core_throttle_count)
    package_throttle=$(read_count /sys/devices/system/cpu/cpu0/thermal_throttle/package_throttle_count)
    printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
        "$timestamp" "$package" "$core0" "$core1" "$core2" "$core3" \
        "$current" "$maximum" "$core_throttle" "$package_throttle" >> "$log_file"
    sleep "$interval"
done
