#!/bin/bash
# restore.sh - Restore dotfiles on any Linux distro
# Usage: ./restore.sh [distro-name]
# Example: ./restore.sh cachyos

set -e

DOTFILES="$HOME/.dotfiles"
DISTRO=${1:-linux}
CONFIG_DIR="$DOTFILES/config"

echo ":: Restoring dotfiles on: $DISTRO"

mkdir -p "$HOME/.config"

link_if_exists() {
    local src="$1"
    local dest="$2"
    if [ -e "$src" ]; then
        ln -sf "$src" "$dest"
        echo "  ✓ $(basename $dest)"
    else
        echo "  ✗ $(basename $dest) (source not found)"
    fi
}

echo ":: Linking configs..."

# Hyprland
link_if_exists "$CONFIG_DIR/hypr" "$HOME/.config/hypr"

# Waybar
link_if_exists "$CONFIG_DIR/waybar" "$HOME/.config/waybar"

# Fish shell
link_if_exists "$CONFIG_DIR/fish" "$HOME/.config/fish"
link_if_exists "$CONFIG_DIR/fish_variables" "$HOME/.config/fish_variables"

# Fastfetch
link_if_exists "$CONFIG_DIR/fastfetch" "$HOME/.config/fastfetch"

# ml4w
link_if_exists "$CONFIG_DIR/ml4w" "$HOME/.config/ml4w"

# Kitty
link_if_exists "$CONFIG_DIR/kitty" "$HOME/.config/kitty"

# Btop
link_if_exists "$CONFIG_DIR/btop" "$HOME/.config/btop"

# Shell configs
link_if_exists "$DOTFILES/shell/bashrc" "$HOME/.bashrc"
link_if_exists "$DOTFILES/shell/bash_profile" "$HOME/.bash_profile"
link_if_exists "$DOTFILES/shell/zshrc" "$HOME/.zshrc"

# Vim
link_if_exists "$DOTFILES/vim/vimrc" "$HOME/.vimrc"
link_if_exists "$DOTFILES/vim" "$HOME/.vim"

# Git
link_if_exists "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"

echo ":: Done! Run ./setup-sddm.sh to configure login manager."
