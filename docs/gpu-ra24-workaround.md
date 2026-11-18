# AMDGPU RA24 / KWin workaround

The logged `Unsupported screen format RA24` failures are consistent with an
AMDGPU display format bug: the driver advertises DRM RGBA8888 to compositors,
but the installed display code cannot program that format. AMD's posted fix
adds RGBA8888 support; current mainline source checked on 2026-11-18 still does
not contain `SURFACE_PIXEL_FORMAT_GRPH_RGBA8888`, so the patch has not reached
mainline yet. See [AMD's maintainer response](https://mail-archive.com/amd-gfx%40lists.freedesktop.org/msg155666.html),
[the AMD patch series](https://lore-kernel.gnuweeb.org/amd-gfx/20261116215641.2800595-23-PingLei.Lin%40amd.com/T/),
and [current mainline source](https://raw.githubusercontent.com/torvalds/linux/master/drivers/gpu/drm/amd/display/dc/dc_hw_types.h).

For a reversible trial, the user Plasma environment script
`tools/kwin-force-sw-cursor.sh` sets `KWIN_FORCE_SW_CURSOR=1`. This makes KWin
render the cursor in software instead of using a hardware cursor plane. KDE
describes the variable as a debugging option; the hardware cursor plane is more
efficient. Keep the override only if the next login reduces RA24/modeset errors
without introducing cursor lag or other display problems.

The script is installed at
`~/.config/plasma-workspace/env/kwin-force-sw-cursor.sh` and is applied on the
next Plasma login. Remove that symlink and log out/in to roll back. No kernel,
GPU firmware, display mode, or running session was changed by installing it.

After the next login, compare the kernel journal for `RA24`, KWin atomic
modeset failures and output configuration failures. A successful trial is not
proof of hardware health; it only confirms that avoiding the hardware cursor
plane suppresses this driver path.
