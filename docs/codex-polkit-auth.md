# Polkit authentication from Codex sessions

Use this procedure when a privileged host operation is authorized but `sudo` cannot authenticate from the Codex execution session. A sudo prompt in an agent PTY may not be visible to the user; this host also has `NoNewPrivs=1`, and its sudo configuration is not root-owned, so sudo cannot elevate from this sandbox.

## Verify the graphical authentication path

Run a harmless Polkit command using an interactive PTY and the normal command approval flow:

```sh
pkexec /usr/bin/true
```

A successful exit status (`0`) confirms that `pkexec` can complete authorization in the current session. The command makes no system changes. If the prompt is not visible or authorization cannot complete, stop the command; do not ask the user to send a password in chat.

## Run an authorized host operation

After the user has authorized the specific operation, invoke the narrowly scoped command through `pkexec`, with an interactive PTY and an escalation justification. Keep the command fixed and reviewable; avoid broad root shells. If it waits for authentication, poll that same command session. If the user cannot see the prompt, cancel without making changes and ask them to run the reviewed command in a visible terminal.

Do not assume authorization for one harmless `pkexec /usr/bin/true` check authorizes unrelated privileged changes. Follow the user's explicit authorization for each system change and verify its effects from the relevant sysfs, service, or configuration state.

## Verified example (2026-11-18)

`pkexec /usr/bin/true` completed with exit status `0`. Using the same Polkit path, the previously requested runtime CPU policy restoration completed: `/sys/devices/system/cpu/intel_pstate/no_turbo` became `0`, and `/sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq` became `4200000` kHz. `max_perf_pct` remained `100`. The CPU package was 53 C at verification. These policy changes are runtime-only and revert on reboot or later policy changes.

The system recon report tracks the current GDS, CPU, and GPU findings: [`SYSTEM_RECON.md`](../SYSTEM_RECON.md).
