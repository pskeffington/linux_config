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

- Gather Data Sampling: vulnerable, reported as lacking microcode
- MDS and MMIO stale data: mitigations active; kernel reports SMT remains vulnerable
- L1TF, Meltdown, Retbleed, Spectre v1/v2, SRBDS, Speculative Store Bypass, and TSX Async Abort: mitigations reported active
- These are kernel status strings, not an independent security assessment. Review firmware and microcode updates for this CPU.

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