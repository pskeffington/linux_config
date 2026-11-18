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

The menu-entry generator is installed as `/etc/grub.d/41_gds_fallback` and adds
an opt-in entry after the normal Garuda entries. The original configuration is
backed up at `/boot/grub/grub.cfg.pre-gds`; it was byte-for-byte identical to
the original before the update. The active configuration passed
`grub-script-check`, its header retains `set default="0"`, and the normal
Garuda entry remains first. The machine has not rebooted or selected the
fallback, so the current kernel remains vulnerable.

The installed entry is for one-boot testing. It appends
`gather_data_sampling=force`, which on this CPU is expected to report
`Mitigation: AVX disabled, no microcode`. Selecting it disables AVX; check
AVX/XSAVE-dependent applications first. To verify the test, run:

```sh
cat /sys/devices/system/cpu/vulnerabilities/gather_data_sampling
```

## Installing or rolling back the entry

The authenticated host command path used in this environment is documented in
[`codex-polkit-auth.md`](codex-polkit-auth.md). Use Polkit only after the user
authorizes the specific system change. The GRUB update was performed in stages:
back up the current config, install the generator, generate a temporary config,
run `grub-script-check`, confirm default entry 0 and menu ordering, then install
the validated file. Do not write an unvalidated generated config to the boot
path.

To roll back while retaining the current running system:

```sh
pkexec /bin/sh -c 'rm -f /etc/grub.d/41_gds_fallback; cp -a /boot/grub/grub.cfg.pre-gds /boot/grub/grub.cfg; grub-script-check /boot/grub/grub.cfg'
```

This restores the saved configuration and removes the optional generator. The
fallback must remain opt-in unless the AVX compatibility tradeoff has been
accepted.
