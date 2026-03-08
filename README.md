```markdown
# 💀 My Ultimate RAM-Booting Security Lab

![Hyprland Demo](https://raw.githubusercontent.com/vaxerski/Hyprland/main/assets/hyprland.gif)

A professional-grade, disposable, and fully encrypted hacking environment built on **NixOS**. This system runs entirely in RAM to ensure zero forensic footprint on the host machine while maintaining high performance with native **Nvidia T1000** drivers.

---

## 🚀 Core Features
* **Volatile Root:** Everything runs in `tmpfs` (RAM). Power off = Data gone.
* **Encrypted Persistence:** Automatic LUKS mounting of `/dev/disk/by-label/DATA` to `/home/nixos/work`.
* **Hardware Powered:** Full proprietary Nvidia driver support for GPU-accelerated tasks.
* **Security Stack:** Pre-configured with Burp Suite, Nmap, Metasploit, and modern web discovery tools.
* **The Panic Button:** A dedicated Waybar module to instantly wipe RAM and trigger a cold reboot.

---

## ⌨️ Global Keybinds
| Keybind | Action |
| :--- | :--- |
| `Super + Q` | Open Terminal (Kitty) |
| `Super + E` | Open Text Editor (Kate) |
| `Super + B` | Open Burp Suite |
| `Super + W` | Open Chromium |
| `Super + M` | Exit Hyprland |
| **💀 Click** | **PANIC REBOOT** |

---

## 🛠 Quick Operations Manual

### 1. Building the ISO
If you are on the build machine (Parrot), run:
```bash
git pull
git add .
nix build .#ventoy-nix

```

The resulting ISO will be in `result/iso/nixos.iso`.

### 2. The DATA Partition

Ensure your persistent USB partition is formatted as **ext4** and labeled **DATA**.
To create it manually:

```bash
mkfs.ext4 -L DATA /dev/sdXy

```

### 3. Adding New Tools

Edit the `environment.systemPackages` block in `flake.nix` on GitHub, then pull and rebuild. Nix handles the dependencies and configuration automatically.

---

## 📂 Repository Structure

* `flake.nix` - The "DNA" of the system. Controls drivers, packages, and firewall.
* `config/` - Custom configuration files (linked to RAM at boot).
* `shell/` - Custom shell scripts and aliases.
* `scripts/` - Automation scripts for restore and setup.

---

## 🔧 Scripts

Think of the restore process as a three-act production:

### Act 1: CLI Foundation
```bash
~/.dotfiles/scripts/install.sh
```
**install.sh** handles your command line identity. It symlinks `.bashrc`, `.zshrc`, `.vimrc`, and `.gitconfig`. These configs work on ANY Linux, macOS, WSL - even Windows. Your terminal looks and feels the same everywhere.

### Act 2: Desktop Identity
```bash
~/.dotfiles/scripts/restore.sh cachyos
```
**restore.sh** handles your graphical desktop. It symlinks Hyprland, Waybar, Fish shell, ml4w, Kitty, Btop, Fastfetch configs from `~/.dotfiles/config/` to `~/.config/`. These are Wayland-specific and only matter on a Hyprland desktop.

### Act 3: Login Manager
```bash
~/.dotfiles/scripts/setup-sddm.sh
```
**setup-sddm.sh** configures SDDM to default to Hyprland. Run with sudo. No more booting into Plasma by accident.

### Full Production (Any Linux Distro)
```bash
git clone https://github.com/richknowles/.dotfiles ~/.dotfiles
~/.dotfiles/scripts/install.sh
~/.dotfiles/scripts/restore.sh cachyos
~/.dotfiles/scripts/setup-sddm.sh
```

### Script Breakdown

| Script | Lines | Purpose |
| :--- | :--- | :--- |
| [`restore.sh`](scripts/restore.sh) | 63 | Symlinks all configs from `~/.dotfiles/config/` to `~/.config/` on any Linux distro. Supports hypr, waybar, fish, fastfetch, ml4w, kitty, btop, shell, vim, and git. Uses `link_if_exists` function - only creates symlink if source exists. Prints ✓ for success, ✗ for missing source. |
| [`setup-sddm.sh`](scripts/setup-sddm.sh) | 14 | Configures SDDM login manager to default to Hyprland session. Creates `/etc/sddm.conf.d/default-session.conf` with `Session=hyprland.desktop`. Run with sudo after restore. |

### Other Scripts

| Script | Purpose |
| :--- | :--- |
| [`collect-cachyos-configs.sh`](scripts/collect-cachyos-configs.sh) | Collects current CachyOS/ML4W/Hyprland configs into the dotfiles repo. Run from `~/.dotfiles` directory. |
| [`collect-wsl-configs.sh`](scripts/collect-wsl-configs.sh) | Collects WSL configs into the dotfiles repo. |
| [`packages.sh`](scripts/packages.sh) | Saves current package lists (pacman, AUR, flatpak) to `packages/` directory. |
| [`install-packages.sh`](scripts/install-packages.sh) | Installs packages from saved lists. |
| [`install.sh`](scripts/install.sh) | Main installer - symlinks shell, git, and vim configs. Supports `--all`, `--shell`, `--git`, `--vim` flags. |

```
