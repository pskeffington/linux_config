# One-boot GDS mitigation test

The installed i7-6700K reports `Vulnerable: No microcode` at microcode `0xf0`.
The currently installed public microcode image and board firmware do not
provide the GDS mitigation. Linux documents `gather_data_sampling=force` as a
fallback that disables AVX when affected hardware lacks mitigation microcode.
It also warns that applications with incorrect AVX/XSAVE feature checks can
fail. See the [Linux GDS documentation](https://www.kernel.org/doc/html/latest/admin-guide/hw-vuln/gather_data_sampling.html).

To try the fallback for one boot without changing GRUB files or the default
entry:

1. Restart when convenient and show the GRUB menu (the current configuration
   uses a visible menu and a five-second timeout).
2. Highlight the normal Garuda/Linux Zen entry and press `e` to edit it for
   this boot only.
3. Find the line beginning with `linux` that loads `vmlinuz-linux-zen`. Append
   `gather_data_sampling=force` to the end of that line. Do not remove or alter
   the existing arguments.
4. Boot the edited entry with `Ctrl`+`X` or `F10`. The edit is temporary; the
   next boot uses the unchanged default entry.
5. Verify the result with:

   ```sh
   cat /sys/devices/system/cpu/vulnerabilities/gather_data_sampling
   ```

   Expected on this CPU: `Mitigation: AVX disabled, no microcode`.

Before choosing a persistent setting, check the applications important to this
system, especially AVX-using media, DSP, scientific, and virtual-machine
software. Reboot normally to return to the original feature set. Do not set
`gather_data_sampling=force` in the default GRUB command line unless the AVX
tradeoff is accepted.

An optional menu-entry generator is available at
`tools/grub-gds-fallback`. If installed as `/etc/grub.d/41_gds_fallback` and
followed by regenerating GRUB configuration, it adds a separate entry while
preserving the normal first/default entry (`GRUB_DEFAULT=0`). The entry is
still opt-in: it disables AVX only if explicitly selected. The generator has
been validated against the current kernel/initrd paths, LUKS UUID, and root
filesystem UUID. No GRUB file or boot default has been changed as part of this
investigation.
