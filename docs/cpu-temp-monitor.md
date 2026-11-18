# CPU temperature monitor

The user service samples CPU package/core temperatures, current and maximum CPU
frequency, CPU0 core/package thermal-throttle event counters, aggregate CPU busy
percentage, and 1-minute load every 10 seconds. It writes CSV to
`${XDG_STATE_HOME:-~/.local/state}/cpu-temp-monitor/` and rotates the active file
at 5 MiB, retaining four previous files. When the CSV schema changes, the
previous file is preserved as the first rotated archive and a fresh header is
written.

Install and start it for the current user:

```sh
mkdir -p ~/.config/systemd/user
ln -s /home/sysadmin/github/linux_config/systemd/user/cpu-temp-monitor.service \
  ~/.config/systemd/user/cpu-temp-monitor.service
systemctl --user daemon-reload
systemctl --user enable --now cpu-temp-monitor.service
```

Inspect status and recent log rows:

```sh
systemctl --user status cpu-temp-monitor.service
tail -n 20 ~/.local/state/cpu-temp-monitor/temperature.csv
```

The service is read-only with respect to CPU controls. The first `cpu_busy_pct`
row after startup or log rotation is blank because it needs two `/proc/stat`
samples; later values are the aggregate busy percentage over the preceding
interval. Empty temperature fields mean the corresponding `coretemp` sysfs
sensor was not exposed. Thermal throttle counters are cumulative since boot;
compare successive rows for changes.
