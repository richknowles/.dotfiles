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

```
