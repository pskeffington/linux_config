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
- Reported CPU frequency was 3.51 GHz and system load average was 2.65–3.61. The process list available to this session did not reveal the workload causing host load.
- A temporary 2.0 GHz cap was attempted with `sudo -n`; it failed with exit code 1 because a password is required. No CPU limit or other system setting was changed.
- Current remediation priority: stop CPU-heavy work and physically inspect CPU cooler mounting, fan operation, and airflow after the system is shut down and cooled. Do not run stress tests until temperatures are safe. Recheck idle temperature and throttling after the cooling system is inspected.
- CPU thermal status: **FAIL / urgent unresolved cooling issue** because it reached critical temperature and the cumulative throttle counters continue to rise. Current snapshot is cooler; physical inspection and safe idle retest are still needed. Current evidence cannot distinguish failed fan, poor cooler contact, blocked airflow, or a transient workload/measurement interval.

### Investigation contract and status

- Task: `CPU-GPU-REPAIR-2026-11-17`; owner: orchestrator (single-session work); source commit: `e9a65a1`.
- Objective: diagnose and remediate the CPU/GPU issues observed on this system; preserve evidence in this repository.
- Scope: read-only system diagnostics and this report. Any boot-configuration, firmware, privileged runtime, or physical hardware changes require the relevant user choice/approval and safe access.
- Acceptance: CPU remains below the 80 C high threshold at idle with no increasing thermal-throttle time; GDS is either verified mitigated or the selected fallback is configured and verified with its AVX impact understood; GPU errors are traced to a supported driver path or reproducibly resolved; updated evidence is committed and pushed.
- Dependencies/blockers: CPU cooler needs physical inspection due current critical temperature; privileged frequency cap requires an interactive password and was not applied; user selection for GDS fallback remains pending; display runtime verification is limited by this diagnostic shell not having an accessible desktop session.
- Rollback: no system configuration changes have been made. Any future GRUB or CPU frequency change must retain a normal boot/recovery path and be reversible.

### GDS follow-up (2026-11-17)

- Observed: `/sys/devices/system/cpu/vulnerabilities/gather_data_sampling` and `lscpu` both report `Vulnerable: No microcode`.
- Observed: kernel log reports microcode loaded early from `0xc2` to `0xf0`; current per-CPU microcode sysfs also reports `0xf0`.
- Observed: kernel command line does not include `gather_data_sampling=off`, `mitigations=off`, or a forced GDS option. The kernel default is active, but the GDS microcode capability needed to mitigate this CPU is absent.
- Intel's Linux kernel documentation confirms `gather_data_sampling=force` uses GDS-capable microcode when available, otherwise disables AVX. This remediation was investigated but not applied; no changes have been made to boot configuration or firmware.
- Sources: [Linux GDS documentation](https://www.kernel.org/doc/html/latest/admin-guide/hw-vuln/gather_data_sampling.html), [Intel affected processor list](https://github.com/intel/Intel-affected-processor-list/blob/main/Intel_affected_processor_list.csv), [ASUS BIOS support page](https://www.asus.com/us/supportonly/maximus%20viii%20hero%20alpha/helpdesk_bios/).

## Memory and storage

- RAM: 32 GiB; about 27 GiB available in the collection snapshot
- Swap: 31.3 GiB zram plus a 34.4 GiB encrypted swap partition; no swap used in the snapshot
- Two SSDs: approximately 238.5 GiB SATA and 372.6 GiB NVMe
- Root filesystem: Btrfs on LUKS-encrypted storage, approximately 204 GiB; EFI system partition is 300 MiB
- A separate approximately 372 GiB Btrfs partition was detected without a mount point

## Graphics and peripherals

- GPU: AMD Navi 44, PCI ID 1002:7590; reported by inxi as Radeon RX 9050 / 9060 XT
- Kernel driver: amdgpu; Mesa package version 26.2.7
- Follow-up: inxi reported llvmpipe for both OpenGL and Vulkan while the amdgpu kernel driver was loaded. Confirm the active userspace renderer and Vulkan ICD with glxinfo -B and vulkaninfo --summary in the target desktop session.
- Network adapters detected: Intel I219-V Ethernet (e1000e) and Qualcomm Atheros QCA6174 Wi-Fi (ath10k_pci). Addresses are omitted.

## Development environment

- GCC 16.2.1, Python 3.14.10, Node.js 26.13.1, npm 12.2.2, Git 2.56.1
- base-devel, Mesa, Vulkan loader, Vulkan Radeon and Intel drivers, and Vulkan tools are installed

## Snapshot observations

- Load average was 1.16 / 0.69 / 0.58 across 8 logical CPUs.
- CPU package temperature was 77 C at collection time; GPU edge/junction were 31 C / 34 C and NVMe was 29 C. These are transient sensor readings. Recheck CPU cooling if temperatures remain near this level at idle or rise under sustained work.
- Root filesystem reported 180 GiB available at collection time.

## Collection notes

Collected from read-only system interfaces and installed tool output, including uname, os-release, lscpu, free, lsblk, df, lspci, inxi, pacman, sensors, sysfs CPU frequency policy, and /proc/loadavg. Re-run these checks after hardware, firmware, kernel, or driver changes.
