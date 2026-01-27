# .dotfiles

Personal configuration files for shell, git, vim, and more. Works across **macOS** (including Hackintosh), **Linux** (including Omarchy), and **WSL**.

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
├── shell/           # Shell configurations
│   ├── bashrc       # Bash config with aliases, functions, prompt
│   ├── bash_profile # Login shell config
│   └── zshrc        # Zsh config (if you use zsh)
├── git/             # Git configurations
│   ├── gitconfig    # Git aliases, settings, conditional includes
│   ├── gitignore_global  # Global ignores for all repos
│   ├── gitconfig.macos   # macOS-specific (osxkeychain)
│   ├── gitconfig.linux   # Linux-specific
│   └── gitconfig.wsl     # WSL-specific (Windows credential manager)
├── vim/             # Vim configuration
│   └── vimrc        # Vim settings and keybindings
├── config/          # XDG config files (future use)
├── scripts/         # Utility scripts (future use)
├── wsl/             # WSL-specific configs (future use)
├── macos/           # macOS-specific configs (future use)
├── linux/           # Linux-specific configs (future use)
└── install.sh       # Installation script
```

## Installation

### Full Installation

```bash
./install.sh --all    # or just ./install.sh
```

### Selective Installation

```bash
./install.sh --shell  # Only shell configs (bash/zsh)
./install.sh --git    # Only git config
./install.sh --vim    # Only vim config
```

### Manual Installation

If you prefer to manage symlinks yourself:

```bash
# Shell
ln -s ~/.dotfiles/shell/bashrc ~/.bashrc
ln -s ~/.dotfiles/shell/bash_profile ~/.bash_profile
ln -s ~/.dotfiles/shell/zshrc ~/.zshrc  # if using zsh

# Git
ln -s ~/.dotfiles/git/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/git/gitignore_global ~/.gitignore_global

# Vim
ln -s ~/.dotfiles/vim/vimrc ~/.vimrc
mkdir -p ~/.vim/{backup,swap,undo}
```

## Post-Installation

### Set Your Git Identity

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Reload Your Shell

```bash
source ~/.bashrc  # or source ~/.zshrc
```

## Platform-Specific Features

The configs automatically detect your platform and adjust:

| Feature | macOS | Linux | WSL |
|---------|-------|-------|-----|
| `ls` colors | `-G` flag | `--color=auto` | `--color=auto` |
| Git credential helper | osxkeychain | cache | Windows GCM |
| Homebrew paths | Auto-added | N/A | N/A |
| `explorer.exe` alias | N/A | N/A | Enabled |
| `code.exe` alias | N/A | N/A | Enabled |

## Customization

### Local Overrides

Create these files for machine-specific settings (not tracked by git):

- `~/.bashrc.local` - Local bash settings
- `~/.zshrc.local` - Local zsh settings

### Platform-Specific Extensions

Add platform-specific configs:

- `~/.dotfiles/shell/bashrc.macos`
- `~/.dotfiles/shell/bashrc.linux`
- `~/.dotfiles/shell/bashrc.wsl`

## Key Aliases

### Navigation
- `..` / `...` / `....` - Go up directories
- `ll` - Long list with details
- `la` - List all including hidden

### Git
- `g` - git
- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `gd` - git diff
- `glog` - Pretty git log graph

### Functions
- `mkcd <dir>` - Create directory and cd into it
- `extract <file>` - Extract any archive type

## Useful Git Aliases

From the gitconfig:

```bash
git lg      # Pretty log graph
git last    # Show last commit
git undo    # Undo last commit (soft)
git cleanup # Delete merged branches
```

## Backup

When running `install.sh`, existing files are backed up to:
```
~/.dotfiles_backup/<timestamp>/
```

## Adding New Configs

1. Add the config file to the appropriate directory
2. Update `install.sh` to symlink it
3. Commit and push

## Syncing Across Machines

```bash
# On a new machine
git clone https://github.com/richknowles/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh

# To update
cd ~/.dotfiles
git pull
./install.sh  # Re-run to pick up any new files
```

## Future Additions

Directories ready for expansion:
- `config/` - For XDG configs (~/.config/*)
- `scripts/` - Utility scripts
- `wsl/` - WSL-specific files (wsl.conf, etc.)
- `macos/` - macOS-specific (Brewfile, defaults, etc.)
- `linux/` - Linux-specific (systemd units, etc.)

## Omarchy Notes

When switching to Omarchy, you may want to:
1. Check if they have their own dotfile management
2. Source these configs from their defaults
3. Add any Omarchy-specific configs to `linux/`

## License

MIT - Feel free to fork and customize!
