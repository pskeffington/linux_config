# CPU/GPU and platform repair roadmap

Updated: 2026-11-18 (EST)

This roadmap tracks the hardware and driver issues investigated on this host. It separates confirmed behavior from possible hardware causes. No fault is diagnosed solely from a missing sensor or a resume-time message.

## Current operating baseline

- CPU: Intel Core i7-6700K. Turbo is currently disabled at runtime and CPU policy is capped at 3.0 GHz. The persistent monitor is active. Analysis of 3,052 ordinary-use samples over about 8.5 hours at this cap found 32–55 C package temperature and no added thermal-throttle duration. With Turbo enabled, heavy SDR work previously drove the package to 99–100 C and increased throttle time; the cap was restored.
- GDS: the kernel reports `Vulnerable: No microcode` at microcode revision `0xf0`. An optional GRUB entry using `gather_data_sampling=force` is installed, syntax-checked, and not the default. Selecting it disables AVX on this CPU.
- GPU: Radeon RX 9060 XT uses accelerated `radeonsi` OpenGL and RADV Vulkan at PCIe 32 GT/s x16. The current boot journal has startup `Unsupported screen format RA24`/CRTC messages; no matching errors appeared after 20:00 on the latest check. Mainline lacks the required AMD RGBA8888 DC surface format; the AMD fix remains a posted patch series. The KWin software-cursor hook is installed, but the current Plasma session predates it.
- NVMe: Intel SSD 750 AIC reports SMART overall-health PASS, 0 critical warnings, 0 media/integrity errors, 0 error-log entries, and 1% used. Endpoint `0d:00.0` supports x4 but is linked at 8 GT/s x1; upstream root port `00:1c.7` itself reports maximum width x1. The motherboard path is therefore currently x1; physical slot mapping is unavailable, so verify the card is in ASUS slot 6 (`PCIEX4_3`) with UEFI `PCIe Mode` before considering a physical change. The drive logged one namespace-identify failure during hibernation resume, then restored its queues. Link width and SMART health do not establish a device defect.
- Board telemetry: NCT6793D is detected, but `nct6775` is blocked by an ACPI SystemIO conflict with `\\_GPE.HWM`; no CPU fan RPM or board temperature is exposed. Do not force access to the ACPI-reserved region without a reviewed test and recovery plan.

## Priority 1: Keep the CPU inside known limits

**Status: runtime cap holding; Turbo-on thermal behavior requires physical/telemetry follow-up.**

1. Keep the current runtime setting (`no_turbo=1`, maximum 3,000,000 kHz) while ordinary work continues. The measured capped interval remained below 80 C with flat throttle counters.
2. Do not run another synthetic stress load. The existing natural SDR workload was already enough to reach the CPU's 100 C critical threshold under Turbo.
3. Before considering Turbo again, inspect cooler mounting/contact, thermal paste coverage, fan direction and clearance, CPU_FAN connection and fan curve, case airflow, and motherboard/VRM temperatures. Use firmware Q-Fan readings or an external tachometer if Linux cannot access the board sensors. No cooler defect is currently proven.
4. If a later representative workload is approved, define a stop threshold before starting and observe package temperature and per-core/package throttle-time deltas continuously. Stop at 85 C or any rapidly rising throttle duration; do not aim for the 100 C limit.

**Reboot gate:** the 3 GHz/Turbo-off policy is runtime-only; no boot-time rule that reapplies it was found. A reboot may restore the firmware/kernel default Turbo policy. The earlier general reboot request is superseded. Before any GDS reboot test, choose one of:
- approve a reversible boot-time 3 GHz/Turbo-off service (this limits every boot until removed); or
- defer reboot until the user can ensure the cap is reapplied before high-load SDR work starts.

The GDS test is not authorized by installing its menu entry. The normal GRUB entry remains default 0. If a test is later approved, verify `/sys/devices/system/cpu/vulnerabilities/gather_data_sampling` reports `Mitigation: AVX disabled, no microcode`, check the AVX impact on required applications, then return to the normal boot entry.

## Priority 2: Recover the NVMe x4 link

**Status: health PASS; link-width issue unresolved; physical location not identified.**

1. First identify the card's physical slot. The endpoint is x4-capable, but its current upstream root port `00:1c.7` exposes only x1; this indicates that the board route itself is x1, not a normal x4 port down-training. The physical route is unknown because Linux exposed no PCI slot map. If the card is not in ASUS manual slot 6 (`PCIEX4_3`), power down and plan a move to that x4 slot. If it is in slot 6, check UEFI `PCIEX4_3/M.2` is set to `PCIe Mode`; the manual says this enables the slot and disables M.2, while `M.2 Mode` does the reverse.
2. If the card is in the correct x4 slot and firmware mode is correct, inspect seating and contacts. Do not reseat or move it while powered.
3. After any owner-approved physical/firmware adjustment, verify sysfs reports current link width 4 (maximum 4) and inspect the NVMe health/error log again. Compare real workload throughput if needed.
4. Keep monitoring for NVMe I/O errors outside hibernation/resume. The current SMART log is clean; the 253 unsafe-shutdown count is historical and does not identify a cause.

PCIe bridge-window allocation failures were on a separate Thunderbolt branch from the NVMe root port. The journal alone does not connect them to the NVMe resume message.

## Priority 3: Test the reversible KWin cursor workaround

**Status: installed but not tested in the active session.**

1. At a convenient time, save work and start a fresh Plasma session so `~/.config/plasma-workspace/env/kwin-force-sw-cursor.sh` is sourced by KWin.
2. Confirm `KWIN_FORCE_SW_CURSOR=1` in the new session if the environment is accessible.
3. Compare kernel `RA24` and CRTC error counts before and after login while using the desktop normally. Keep the override only if the new session reduces the observed errors or modeset failures; remove the symlink to roll back.

The current compositor started before the hook existed, so current-session results cannot validate the workaround. No logout/restart has been performed.

## Priority 4: Track the upstream AMD display fix

**Status: root cause linked to AMD DC format handling; released fix not identified.**

The exact RA24 message is explained by AMD DC advertising DRM RGBA8888 while rejecting the matching surface format. Linux mainline still lacks `SURFACE_PIXEL_FORMAT_GRPH_RGBA8888`; AMD's support/crossbar patches are posted for review. Continue using released kernel updates and recheck this upstream source/patch status before considering a custom kernel. Do not build or install an unreviewed multi-patch kernel stack just to test the format fix.

## Hardware-fault assessment

- CPU cooling/control: thermal-limit events are confirmed under Turbo and heavy SDR work. The 3 GHz cap is stable under the observed natural-use interval. Cooler, mounting, fan/VRM behavior, and platform limit signals remain unisolated; no specific hardware part is condemned.
- GPU: hardware acceleration, full x16 link, and zero endpoint AER counters are verified. The evidence points to a display-format/driver/compositor compatibility issue; no GPU hardware fault is established.
- NVMe: SMART passes with no media/error-log entries and zero endpoint AER counters. The x1 negotiated width is a configuration/seating/link-training issue to investigate, not proof of SSD failure.
- Board fan/VRM telemetry: unavailable because the driver conflicts with firmware ACPI resources. The `acpi_enforce_resources=lax` parameter would permit legacy access to ACPI-claimed regions; it remains untested and should not be enabled without reviewing possible firmware/driver interaction.

## Evidence and source links

- [System reconnaissance and timestamped evidence](../SYSTEM_RECON.md)
- [GDS one-boot test and rollback](gds-one-time-test.md)
- [Polkit authentication procedure](codex-polkit-auth.md)
- [GPU RA24 workaround](gpu-ra24-workaround.md)
- [CPU temperature monitor](cpu-temp-monitor.md)
- [Linux ACPI resource policy](https://docs.kernel.org/next/admin-guide/kernel-parameters.html#acpi-enforce-resources)
- [Intel SSD 750 product specification](https://www.intel.com/content/dam/www/public/us/en/documents/product-specifications/ssd-750-spec.pdf)
- [ASUS Maximus VIII Hero Alpha manual](https://dlcdnets.asus.com/pub/ASUS/mb/LGA1151/MAXIMUS_VIII_HERO_ALPHA/E11194_MAXIMUS_VIII_HERO_ALPHA_UM_V2_WEB.pdf)
- [AMD Linux mainline display format source](https://raw.githubusercontent.com/torvalds/linux/master/drivers/gpu/drm/amd/display/dc/dc_hw_types.h)
- [AMD RGBA8888 patch series](https://lore-kernel.gnuweeb.org/amd-gfx/20261116215641.2800595-23-PingLei.Lin%40amd.com/T/)
