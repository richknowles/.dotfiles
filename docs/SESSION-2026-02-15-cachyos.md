# CachyOS Migration Session

**Date:** February 15, 2026
**Session:** Migrating dotfiles from Omarchy to CachyOS + ML4W

---

## What Happened

- Omarchy wiped macOS Sonoma OpenCore install on NVMe 2 without confirmation
- Installed CachyOS with ZFS instead
- Using ML4W (My Linux 4 Workstation) for Hyprland desktop
- Everything running great

## Current Hardware Setup

| Machine | Specs | OS |
|---------|-------|----|
| **P15 Gen 1 Laptop** | i7 10th Gen, 32GB RAM, 2x 1TB NVMe, Quadro T1000 | Dual boot |
| **Tower** | 5960X | Proxmox (ZFS, 18+ months uptime) |

### P15 Drive Layout
| Drive | OS | Notes |
|-------|-----|-------|
| **NVMe 0** | macOS Sonoma (OpenCore) | Pending reinstall |
| **NVMe 1** | CachyOS (ZFS) | Daily driver |

### Hackintosh Notes
- **GPU:** Quadro T1000 (Turing) has NO macOS support - must use Intel UHD 630
- **Recommendation:** Sonoma (14.x) over Sequoia (15.x) - more stable kexts for 10th gen
- **Boot:** OpenCore, separate from CachyOS bootloader

### P15 Software Stack
- **OS:** CachyOS (Arch-based, rolling release)
- **Filesystem:** ZFS
- **WM:** Hyprland
- **Desktop:** ML4W
- **Bar:** Waybar
- **Terminal:** Kitty
- **Shell:** Fish
- **GPU:** Nvidia Quadro T1000 (4GB VRAM)

### VMs on Proxmox
- Kali Linux (bug bounty hunting)

## Issues Fixed

### eza libllhttp version mismatch
- **Problem:** `eza: error while loading shared libraries: libllhttp.so.9.2`
- **Cause:** `llhttp` updated to 9.3 but `eza` was built against 9.2
- **Fix:** `sudo ln -s /usr/lib/libllhttp.so.9.3 /usr/lib/libllhttp.so.9.2`
- **Permanent fix:** Wait for CachyOS to rebuild eza against new llhttp

## Changes to Dotfiles Repo

1. Removed Omarchy references from README
2. Updated README for CachyOS/ML4W/Hyprland setup
3. Added `scripts/collect-cachyos-configs.sh` collector
4. Added Known Fixes section to README
5. Updated hardware info (RIP macOS Sonoma)

## CachyOS Config Locations

| Config | Path |
|--------|------|
| Hyprland | `~/.config/hypr/` |
| Waybar | `~/.config/waybar/` |
| ML4W | `~/.config/ml4w/` |
| Kitty | `~/.config/kitty/` |
| Fish | `~/.config/fish/` |
| btop | `~/.config/btop/` |

## Packages

- 236 explicitly installed packages
- Running: Hyprland, Kitty, Fish, btop, Alacritty (backup)
- CachyOS-specific: cachyos-fish-config, cachyos-kernel-manager, cachyos-settings

## Next Steps

- [ ] Run `collect-cachyos-configs.sh` to save all configs
- [ ] Set up hunting VM on Proxmox (Kali running)
- [ ] Run `install-tools.sh` on Kali VM
- [ ] Start Okta recon on Bugcrowd
- [ ] Reinstall macOS Sonoma (OpenCore) on NVMe 0
  - Use Intel UHD 630 for display (Quadro T1000 unsupported)
  - Keep OpenCore EFI separate from CachyOS
  - Consider BIOS boot menu for OS selection

---

*Generated during Claude Code session - February 15, 2026*
