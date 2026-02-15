# .dotfiles

Personal configuration files across **CachyOS** (Hyprland/ML4W), **macOS** (Hackintosh Sonoma), and **WSL**.

## Current Setup

| Drive | OS | Desktop | Notes |
|-------|-----|---------|-------|
| **NVMe 0** | macOS Sonoma (OpenCore) | Aqua | Pending reinstall, Intel UHD 630 only (Quadro T1000 unsupported) |
| **NVMe 1** | CachyOS (ZFS) | Hyprland / ML4W | Daily driver, Fish shell |
| **Tower** | Proxmox (ZFS) | - | 5960X, VMs, 18+ months uptime |

**Bootloader:** rEFInd (auto-detects all OSes)

## Quick Start

```bash
# Clone the repo
git clone https://github.com/richknowles/.dotfiles.git ~/.dotfiles

# Run the installer
cd ~/.dotfiles
./install.sh
```

## What's Included

```
~/.dotfiles/
├── config/              # XDG configs (~/.config)
│   ├── hypr/            # Hyprland (WM, lock, paper, idle)
│   ├── waybar/          # Waybar (status bar)
│   ├── ml4w/            # ML4W dotfiles manager
│   ├── kitty/           # Kitty terminal
│   ├── fish/            # Fish shell
│   ├── neofetch/        # Neofetch
│   ├── mc/              # Midnight Commander
│   └── rclone/          # (ignored - has creds)
│
├── shell/               # Shell configurations
│   ├── bashrc           # Bash config (cross-platform)
│   ├── bashrc.wsl       # WSL-specific bash
│   ├── zshrc            # Zsh config
│   └── ...
│
├── git/                 # Git configurations
│   ├── gitconfig        # Main config
│   ├── gitconfig.macos  # macOS (osxkeychain)
│   ├── gitconfig.linux  # Linux
│   ├── gitconfig.wsl    # WSL (Windows GCM)
│   └── gitignore_global # Global ignores
│
├── vim/                 # Vim configuration
│   └── vimrc
│
├── linux/               # Linux-specific
│   ├── packages-cachyos.txt  # Installed packages
│   ├── packages-aur.txt      # AUR packages
│   ├── zfs-pools.txt         # ZFS pool info
│   └── kvm-vms.txt           # VM list
│
├── wsl/                 # WSL configs
│   ├── wsl.conf         # Per-distro settings
│   ├── .wslconfig       # Global WSL2 settings
│   └── .wsl-config      # Custom config
│
├── windows/             # Windows configs (archived)
│   ├── collect-windows-configs.ps1
│   ├── windows-terminal.json
│   ├── vscode-settings.json
│   └── ...
│
├── scripts/
│   ├── collect-cachyos-configs.sh  # CachyOS collector
│   ├── collect-wsl-configs.sh      # WSL collector
│   └── bounty/                     # Bug bounty toolkit
│       ├── install-tools.sh
│       ├── recon.sh
│       └── okta-recon.sh
│
├── docs/                # Session notes
│   └── SESSION-*.md
│
└── install.sh           # Auto-symlink installer
```

## Config Collectors

### CachyOS / ML4W / Hyprland
```bash
cd ~/.dotfiles
bash scripts/collect-cachyos-configs.sh
```
Collects: Hyprland, Waybar, ML4W, Kitty, Fish, btop, packages, ZFS info, VM list

### WSL (Ubuntu)
```bash
bash scripts/collect-wsl-configs.sh
```

### Windows (PowerShell)
```powershell
& "\\wsl$\Ubuntu-22.04\home\rich\.dotfiles\windows\collect-windows-configs.ps1"
```

## Installation

### Full Installation
```bash
./install.sh --all    # or just ./install.sh
```

### Selective Installation
```bash
./install.sh --shell  # Only shell configs
./install.sh --git    # Only git config
./install.sh --vim    # Only vim config
```

### Manual Symlinks (CachyOS)
```bash
# Hyprland (backup ML4W originals first)
ln -sf ~/.dotfiles/config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf

# Kitty
ln -sf ~/.dotfiles/config/kitty/kitty.conf ~/.config/kitty/kitty.conf

# Fish
ln -sf ~/.dotfiles/config/fish/config.fish ~/.config/fish/config.fish

# Git
ln -sf ~/.dotfiles/git/gitconfig ~/.gitconfig
```

## Bug Bounty Toolkit

See [scripts/bounty/README.md](scripts/bounty/README.md)

```bash
# Install tools on hunting VM
cd ~/.dotfiles/scripts/bounty
./install-tools.sh

# Run recon
./okta-recon.sh okta.com
./recon.sh target.com program-name
```

## Known Fixes

### eza libllhttp version mismatch (CachyOS)
When `llhttp` updates but `eza` isn't rebuilt yet:
```bash
# Check the issue
ldd /usr/bin/eza | grep "not found"
# Symlink the new version
sudo ln -s /usr/lib/libllhttp.so.9.3 /usr/lib/libllhttp.so.9.2
```

## Syncing Across Machines

```bash
# On a new machine
git clone https://github.com/richknowles/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh

# To update
cd ~/.dotfiles
git pull
./install.sh
```

## License

MIT - Feel free to fork and customize!
