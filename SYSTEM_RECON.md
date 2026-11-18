# System Reconnaissance

Snapshot date: 2026-11-17

This file records a sanitized hardware and software baseline for the worker. Values are a point-in-time snapshot, not a guarantee of current state. Host name, account name, network addresses, MAC addresses, disk UUIDs, serial numbers, and secrets are intentionally omitted.

## Platform

- Distribution: Garuda Linux (Arch Linux family), x86_64
- Kernel: 7.3.4-zen2-2-zen (Linux Zen)
- Init: systemd 262
- Desktop: KDE Plasma 6 on Wayland
- Firmware: UEFI; ASUS MAXIMUS VIII HERO ALPHA, firmware build 3801 (2018-03-14)
- Package manager: pacman; approximately 1,772 installed packages at collection time

## CPU

- Intel Core i7-6700K (Skylake-S), family 6, model 94, stepping 3
- 1 socket, 4 physical cores, 8 logical CPUs; SMT enabled
- Frequency policy: intel_pstate, powersave governor, 800 MHz minimum, 4.2 GHz maximum; turbo enabled
- Cache: 128 KiB L1 data + 128 KiB L1 instruction (four instances each), 1 MiB L2 (four instances), 8 MiB shared L3
- One NUMA node
- Useful ISA features include AVX2, FMA, AES-NI, BMI1/BMI2, POPCNT, and SSE4.2
- Microcode reported by the kernel: 0xf0

### CPU security status reported by this kernel

- Gather Data Sampling (GDS): `Vulnerable: No microcode`; this is a live, current-kernel status, not an inference from the package being installed
- Exact CPU identity: Intel Core i7-6700K, family 6/model 94/stepping 3 (CPUID signature `0x506e3`)
- Loaded microcode: `0xf0`; the installed `intel-ucode 20261110-1` image contains one matching `0x506e3` record at revision `0xf0`, confirming early microcode loading is working but this image does not update the CPU beyond `0xf0`
- Intel's current affected-processor list shows CPUID `506E3` with MCU level `0xf6` and GDS requiring MCU mitigation. Intel cautions that end-of-servicing-life CPUs may be omitted and their mitigation status may not be evaluated, so this entry does not establish that `0xf6` is available or supported for this particular i7-6700K system.
- Intel's public Linux microcode release notes list the latest publicly released `06-5e-03` update as `0xf0`; the Intel microcode repository's discussion of requested `0xf6` says that revision is not publicly available and that this CPU reached its end-of-servicing-update date. Therefore, no newer public OS microcode path was found for this processor, despite the `0xf6` level shown in the affected-processor guidance.
- ASUS lists BIOS 3801 (2018-04-27) as the newest BIOS for the MAXIMUS VIII HERO ALPHA; its notes mention updated CPU microcode but predate the GDS advisory. No newer board BIOS is listed in the reviewed support page.
- Linux documents `gather_data_sampling=force` as a fallback: when updated GDS microcode is unavailable, it disables AVX use by disabling XSAVE YMM support. Software that incorrectly checks AVX without checking XSAVE YMM can break. This is not enabled in the current boot configuration. Do not enable it without considering AVX2-dependent applications and retaining a boot-recovery path.
- MDS and MMIO stale data: mitigations active; kernel reports SMT remains vulnerable
- L1TF, Meltdown, Retbleed, Spectre v1/v2, SRBDS, Speculative Store Bypass, and TSX Async Abort: mitigations reported active
- These are kernel status strings, not an independent security assessment. Review firmware and microcode updates for this CPU.

### CPU thermal follow-up (2026-11-17)

- Observed at 06:25 EST: `sensors` reported CPU package 99 C, cores 88–99 C, with a 100 C critical threshold; `/sys/class/thermal/thermal_zone0/temp` reported 100000 (100 C). A repeat about 30 seconds later remained at 99 C / 100 C.
- In the same interval, CPU0 `core_throttle_total_time_ms` rose from 65469 to 69937 (4468 ms). This confirms active/recent thermal throttling while package temperature remained at its critical threshold.
- Later observation at 06:57 EST: package 60 C, cores 43–56 C, and thermal zone 59 C; load average 1.12–1.62. Temperatures had fallen below the 80 C high threshold without a configured CPU cap.
- Throttle counters nevertheless rose between the 06:25 and 06:57 observations: CPU0 69937 to 97938 ms (+28.0 s), CPU1 94427 to 219231 ms (+124.8 s). This indicates accumulated thermal throttling during the intervening period, even though the later snapshot was cooler. Counters are cumulative since boot and do not establish the exact temperature or cause during the full interval.
- User reports installing a new large dual-heatsink CPU cooler/fan. At 07:06 EST after this installation, package temperature was 34 C, cores 27–34 C, thermal zone 35 C, and load average 0.77–1.66. CPU0/CPU1 throttle totals were unchanged from 06:57 (97938 / 219231 ms); the 2.0 GHz cap had not been applied. This is a favorable short idle observation after the hardware change, not a sustained-load validation.
- Follow-up at 07:09 EST: package temperature briefly read 85 C, then 79 C at 07:09:32 and 58 C at 07:09:36. CPU0/CPU1 throttle totals were 98326 / 219308 ms at 07:09:32 and remained unchanged in the next two-second samples. Relative to 07:06, cumulative totals increased by only 388 ms / 77 ms over about three minutes. This brief warm transient should be tracked but does not establish a cooler defect or sustained throttling.
- At 07:17 EST: package 65 C, cores 56–65 C, CPU0/CPU1 cumulative thermal-status time 100646 / 227694 ms. Relative to the 07:11:48 readings (98331 / 219308 ms), counters rose by 2.315 / 8.386 seconds over about six minutes. This confirms thermal-status events occurred during that interval; the single temperature snapshot does not establish their timing or trigger.
- At 07:25 EST: package temperature was 46 C, then 30 C five seconds later; CPU0/CPU1/package thermal-status totals were unchanged over that five-second sample. Relative to 07:17, CPU0/CPU1 totals increased from 100646 / 227694 to 121948 / 270828 ms (+21.3 / +43.1 s) over about eight minutes, showing intermittent events between samples. Load average was 0.22–0.24. Turbo remained enabled; current frequency read about 4.2 GHz, while Processor, `intel_powerclamp`, and TCC Offset cooling states were all zero. The visible process list was limited to the diagnostic shell, so it does not identify the host workload.
- Second critical excursion at 16:14 EST: package and Core 0 read 99 C at 16:14:32, then 100 C at both 16:14:48 and 16:14:51. Load average was 3.38 at 16:14:48. From 16:14:48 to 16:14:51, CPU0 and package thermal-status totals each rose by 2055 ms. At 16:15:20 package remained 99 C; by 16:15:41 it had fallen to 48 C, and by 16:16:03 to 37 C. Current frequency fell from 3.87 GHz to 801 MHz; CPU0 and package counters remained flat from 16:15:41 through 16:16:03. From 16:14:51 to 16:15:41, CPU0 total rose by 12.9 seconds and package total by 24.5 seconds, then stopped as temperature recovered. This is a rapid thermal excursion with recovery; it does not identify its trigger or establish a cooler defect.
- Platform telemetry limitation (16:16 EST): visible hwmon devices were `nvme`, `eeepc-wmi`/`asus`, `coretemp`, `ath10k_hwmon`, and `amdgpu`. The ASUS WMI device exposed no temperature or fan input attributes; no CPU fan tachometer or VRM temperature was available. The kernel provides the `nct6775` hwmon module, but it was not loaded; loading it requires elevated privileges unavailable to this diagnostic session. As a result, board/VRM temperatures, CPU fan RPM, and external platform thermal signals could not be correlated with the excursions.
- CPU policy at 07:09: `intel_pstate` active, governor `powersave`, allowed range 800 MHz–4.2 GHz, turbo enabled, `max_perf_pct=100`, and `min_perf_pct=19`. Linux `Processor`, `intel_powerclamp`, and `TCC Offset` thermal-cooling states all read 0. No software frequency ceiling or active Linux cooling state is evident in this snapshot. The power-profiles-daemon query was unavailable from this shell.
- User-requested Turbo check at 07:11: a single `yes` worker was started under an 8-second timeout. The CPU reached 4.2 GHz; the first sample showed package 93 C and cores 85–93 C, so the worker was interrupted before the timeout. CPU0 thermal-status total rose only 5 ms (98326 to 98331); CPU1 remained at 219308 ms. After stopping, package temperature fell to 72 C at 07:11:34 and 69 C at 07:11:48; no `yes` worker remained. This confirms Turbo is active and shows a rapid temperature rise during a brief single-worker load, but does not demonstrate sustained thermal throttling or identify its cause. No longer load was run.
- Interpretation: Linux's `core_throttle_total_time_ms` counts time the CPU thermal-status flag is set; it is not a general software frequency-cap counter. The prior 99–100 C readings establish that the CPU reached its reported thermal threshold, but neither those readings nor the cumulative counter identify the root cause or prove the newly installed cooler is defective. Intel documents a platform-driven external PROCHOT# path as a possible source of processor throttling on supported configurations. Sensor data alone cannot distinguish an internal CPU thermal event, a platform signal/limit, or software-managed frequency policy. No hardware fault is confirmed.
- Reported CPU frequency was 3.51 GHz and system load average was 2.65–3.61. The process list available to this session did not reveal the workload causing host load.
- A temporary 2.0 GHz cap was attempted with `sudo -n`; it failed with exit code 1 because a password is required. No CPU limit or other system setting was changed.
- CPU thermal status: **RECOVERED AFTER REPEATED CRITICAL EXCURSION / TRIGGER OPEN**. After the cooler installation, snapshots have ranged from 27 C to the 100 C critical threshold. The 16:14 excursion reached 100 C twice; CPU0 thermal-status time rose 12.9 seconds and package time 24.5 seconds before cooling to 37 C and returning to 801 MHz. No evidence attributes the event to a defective cooler, software frequency cap, or platform PROCHOT/power signal. A longer load was not run; further load characterization needs an agreed stop threshold and access to platform-limit telemetry.

### Investigation contract and status

- Task: `CPU-GPU-REPAIR-2026-11-17`; owner: orchestrator (single-session work); source commit: `e9a65a1`.
- Objective: diagnose and remediate the CPU/GPU issues observed on this system; preserve evidence in this repository.
- Scope: read-only system diagnostics and this report. Any boot-configuration, firmware, privileged runtime, or physical hardware changes require the relevant user choice/approval and safe access.
- Acceptance: CPU remains below the 80 C high threshold at idle with no increasing thermal-throttle time; GDS is either verified mitigated or the selected fallback is configured and verified with its AVX impact understood; GPU errors are traced to a supported driver path or reproducibly resolved; updated evidence is committed and pushed.
- Dependencies/blockers: CPU cooler has been replaced per user; safe idle snapshot improved, but sustained-load behavior is unverified; privileged frequency cap requires an interactive password and was not applied; user selection for GDS fallback remains pending; display runtime verification is limited by this diagnostic shell not having an accessible desktop session.
- Rollback: no system configuration changes have been made. Any future GRUB or CPU frequency change must retain a normal boot/recovery path and be reversible.

### GDS follow-up (2026-11-17)

- Observed: `/sys/devices/system/cpu/vulnerabilities/gather_data_sampling` and `lscpu` both report `Vulnerable: No microcode`.
- Observed: kernel log reports microcode loaded early from `0xc2` to `0xf0`; current per-CPU microcode sysfs also reports `0xf0`.
- Observed: kernel command line does not include `gather_data_sampling=off`, `mitigations=off`, or a forced GDS option. The kernel default is active, but the GDS microcode capability needed to mitigate this CPU is absent.
- Direct GDS MSR inspection is unavailable from this shell: `/dev/cpu/0/msr` is absent and `rdmsr`/`cpuid` are not installed. No MSRs were read or changed. Linux's upstream handler selects microcode mitigation when `ARCH_CAP_GDS_CTRL` is available; otherwise the documented `force` path disables AVX. The running kernel continues to report `Vulnerable: No microcode`.
- Intel's Linux kernel documentation confirms `gather_data_sampling=force` uses GDS-capable microcode when available, otherwise disables AVX. This remediation was investigated but not applied; no changes have been made to boot configuration or firmware.
- Sources: [Linux GDS documentation](https://www.kernel.org/doc/html/latest/admin-guide/hw-vuln/gather_data_sampling.html), [Linux GDS mitigation code](https://github.com/torvalds/linux/blob/master/arch/x86/kernel/cpu/bugs.c), [Intel affected processor list](https://github.com/intel/Intel-affected-processor-list/blob/main/Intel_affected_processor_list.csv), [Intel Linux microcode release notes](https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files/blob/main/releasenote.md), [Intel microcode discussion of 06-5e-03 revision 0xf6](https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files/issues/100), [ASUS BIOS support page](https://www.asus.com/us/supportonly/maximus%20viii%20hero%20alpha/helpdesk_bios/).

## Memory and storage

- RAM: 32 GiB; about 27 GiB available in the collection snapshot
- Swap: 31.3 GiB zram plus a 34.4 GiB encrypted swap partition; no swap used in the snapshot
- Two SSDs: approximately 238.5 GiB SATA and 372.6 GiB NVMe
- Root filesystem: Btrfs on LUKS-encrypted storage, approximately 204 GiB; EFI system partition is 300 MiB
- A separate approximately 372 GiB Btrfs partition was detected without a mount point

## Graphics and peripherals

- GPU: AMD Navi 44, PCI ID 1002:7590; reported by inxi as Radeon RX 9050 / 9060 XT. User confirms the GPU is also new; no physical GPU fault is established by current evidence.
- Kernel driver: amdgpu; Mesa package version 26.2.7
- Boot log has a burst of `Unsupported screen format RA24` messages with KWin modeset failures. AMD's display maintainer says work item 5339 adds `DRM_FORMAT_RGBA8888` support and prefers that approach over dropping the advertised format. Installed stack at 07:00: Linux Zen 7.3.4, KWin 6.8.3, Mesa 26.2.7, libdrm 2.4.134, firmware 20261019; `pacman -Qu` listed no updates for these packages. The RA24 issue therefore remains a driver/compositor compatibility issue awaiting a shipped fix; current boot logs show no GPU reset/ring-timeout evidence.
- Follow-up at 07:18 EST: GPU edge/junction 34/37 C; HDMI-A-1 connected and DP-1/DP-2 disconnected. Current boot journal totals remain 452 RA24 format errors, 52 KWin modeset failures, 49 output-configuration failures, and 2 CRTC `REG_WAIT` timeouts, all at startup around 03:55:55. No GPU reset or ring-timeout messages were found; the issue remains a startup display-format/software compatibility problem.
- Sources: [Linux Intel thermal throttle counter documentation](https://cdn.kernel.org/doc/html/latest/admin-guide/thermal/intel_thermal_throttle.html), [Intel Skylake S-platform datasheet](https://cdrdv2-public.intel.com/332687/332687_SKL%20Datasheet%20Vol%201_rev010.pdf), [AMD maintainer response on RA24](https://mid.mail-archive.com/amd-gfx%40lists.freedesktop.org/msg155666.html).
- Follow-up: inxi reported llvmpipe for both OpenGL and Vulkan while the amdgpu kernel driver was loaded. Confirm the active userspace renderer and Vulkan ICD with glxinfo -B and vulkaninfo --summary in the target desktop session.
- Network adapters detected: Intel I219-V Ethernet (e1000e) and Qualcomm Atheros QCA6174 Wi-Fi (ath10k_pci). Addresses are omitted.

### Live follow-up (2026-11-18 06:35 EST)

- CPU package temperature was 35 C and core temperatures were 31–35 C. CPU frequency policy remains `powersave`, 800 MHz minimum, 3.0 GHz maximum; current frequency was about 800 MHz. CPU0 thermal-throttle counters were 44,529 core and 110,408 package events, unchanged from the preceding 04:57 EST snapshot. These readings show no active thermal problem during this observation; they do not explain earlier intermittent excursions to 100 C. No stress load was applied.
- GDS still reports `Vulnerable: No microcode`; loaded CPU microcode remains `0xf0`. The kernel command line has no `gather_data_sampling` override. No firmware or boot setting was changed.
- GPU PCI ID `1002:7590` is bound to `amdgpu`. Current GPU telemetry is cool (edge 30 C, junction 32 C, memory 27 C; 13 W). Kernel journal contains repeated pairs of `MODE1 reset`/GPU mode1 reset entries at 08:24, 12:52, 16:13, and 19:29 on Nov 17. At 19:29, `printk: Suspending console(s)` immediately precedes the reset and the driver logs successful SMU resume/reinitialization; this is consistent with the system suspend/resume path, not evidence by itself of a defective card. The kernel boot log still includes the startup RA24 unsupported-format errors and CRTC `REG_WAIT` events. No GPU stress test was run.
- `glxinfo -B` could not connect to display `:0` from this shell. `vulkaninfo --summary` likewise could not create an X surface and then exited with SIGSEGV (systemd-coredump logged the crash at 06:36). These out-of-session diagnostics do not establish which renderer the desktop uses. Verify from the graphical desktop session before drawing conclusions about llvmpipe or Vulkan ICD selection.
- Package versions remain Linux Zen 7.3.4.zen2-2, Mesa 26.2.7-1, libdrm 2.4.134-1, and KWin 6.8.3-1. `pacman -Qu` reported no pending package upgrades. No driver or firmware changes have been made.
- Next diagnostic steps: inspect GPU resume/reset journal context and desktop-session renderer from within the active graphical session; for CPU, capture temperatures, clock, and throttle counter deltas during normal workload if the high-temperature symptom recurs. Do not infer cooler failure or hardware defect from the current cool snapshot. Preserve the current CPU cap until thermal behavior is understood.
- Persistent CPU telemetry was installed on 2026-11-18 as the user systemd service `cpu-temp-monitor.service`. It records package/core temperatures, current/max frequency, and cumulative CPU0 core/package throttle counters every 10 seconds to `~/.local/state/cpu-temp-monitor/temperature.csv`; active file rotation begins at 5 MiB with four prior files retained. The service is enabled and running, and user lingering is enabled (`Linger=yes`) so monitoring starts at boot and continues without an interactive login. Initial rows at 06:43 EST showed package 33–34 C, core readings 26–33 C, frequency varying from about 800 MHz to the unchanged 3.0 GHz cap, and unchanged throttle counters. This monitor changes no CPU controls.
- First sustained log review (1,000 samples from 06:42:31 to 09:31:57 EST) found CPU package temperatures from 31 C to 61 C, with no rise in CPU0 core/package throttle counters (44,529 / 110,408). This period includes normal background use, not a synthetic stress test; it does not explain or rule out the earlier intermittent 100 C events. Latest spot check at 09:31 EST was package 39 C, cores 30–39 C.
- The monitor continued normally through 09:39 EST. The log now contains 1,046 samples from 06:42:31 to 09:39:45 EST; package temperatures remain 31–61 C and throttle counters have not changed. A one-boot GRUB edit procedure for testing `gather_data_sampling=force` is documented in `docs/gds-one-time-test.md`; no boot or firmware setting was changed.
- At 09:50 EST the monitor schema was extended with aggregate CPU busy percentage and 1-minute load to correlate future temperature excursions with workload. The previous 1,098-row CSV was preserved as `temperature.csv.1`; the active CSV now has the new 12-column header. After restart it continued logging (package 33–39 C; CPU busy 30.7–39.8%; 1-minute load 2.58–2.65; throttle counters unchanged). The schema change and service restart did not alter CPU control settings.
- Host-context graphics checks at 09:08 EST resolved the earlier renderer uncertainty: `glxinfo -B` reports accelerated AMD Radeon RX 9060 XT (`radeonsi`, gfx1200) OpenGL on Mesa 26.2.7; `vulkaninfo --summary` reports AMD RADV for PCI device 1002:7590 as the discrete Vulkan device, with llvmpipe only as a secondary CPU device. The previous llvmpipe finding came from an out-of-session diagnostic and does not describe the active desktop.
- Current upstream AMD activity includes a posted patch series adding `DRM_FORMAT_RGBA8888` display support, matching the live RA24 errors. A read of Torvalds' current mainline `dc_hw_types.h` on 2026-11-18 did not find `SURFACE_PIXEL_FORMAT_GRPH_RGBA8888`, so the fix is not in that mainline snapshot. A reversible per-user KWin software-cursor override has been installed for the next Plasma login as a diagnostic workaround; it has not yet been tested in a new session. KDE documents this variable as a debugging option, and software cursor rendering trades some efficiency for avoiding the hardware cursor plane. See [AMD maintainer response](https://mail-archive.com/amd-gfx%40lists.freedesktop.org/msg155666.html), [AMD patch series](https://lore-kernel.gnuweeb.org/amd-gfx/20261116215641.2800595-23-PingLei.Lin%40amd.com/T/), [current mainline source](https://raw.githubusercontent.com/torvalds/linux/master/drivers/gpu/drm/amd/display/dc/dc_hw_types.h), and [KWin environment variables](https://community.kde.org/KWin/Environment_Variables).

## Development environment

- GCC 16.2.1, Python 3.14.10, Node.js 26.13.1, npm 12.2.2, Git 2.56.1
- base-devel, Mesa, Vulkan loader, Vulkan Radeon and Intel drivers, and Vulkan tools are installed

## Snapshot observations

- Load average was 1.16 / 0.69 / 0.58 across 8 logical CPUs.
- CPU package temperature was 77 C at collection time; GPU edge/junction were 31 C / 34 C and NVMe was 29 C. These are transient sensor readings. Recheck CPU cooling if temperatures remain near this level at idle or rise under sustained work.
- Root filesystem reported 180 GiB available at collection time.

## Collection notes

Collected from read-only system interfaces and installed tool output, including uname, os-release, lscpu, free, lsblk, df, lspci, inxi, pacman, sensors, sysfs CPU frequency policy, and /proc/loadavg. Re-run these checks after hardware, firmware, kernel, or driver changes.
