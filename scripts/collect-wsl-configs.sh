#!/bin/bash
# Collect WSL configs and add them to dotfiles repo
# Run this from your ~/.dotfiles directory

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$DOTFILES_DIR/wsl-backup-$(date +%Y%m%d)"

echo "=== WSL Config Collector ==="
echo "Dotfiles dir: $DOTFILES_DIR"
echo ""

# Create directories
mkdir -p "$DOTFILES_DIR/config/fish"
mkdir -p "$DOTFILES_DIR/shell"
mkdir -p "$DOTFILES_DIR/scripts"
mkdir -p "$DOTFILES_DIR/wsl"

echo "=== Checking for configs ==="

# Function to copy if exists
copy_if_exists() {
    src="$1"
    dest="$2"
    name="$3"
    if [ -e "$src" ]; then
        cp -r "$src" "$dest"
        echo "[OK] $name -> $dest"
    else
        echo "[--] $name not found"
    fi
}

# Shell configs
copy_if_exists "$HOME/.bashrc" "$DOTFILES_DIR/shell/bashrc.wsl" ".bashrc"
copy_if_exists "$HOME/.bash_profile" "$DOTFILES_DIR/shell/bash_profile.wsl" ".bash_profile"
copy_if_exists "$HOME/.profile" "$DOTFILES_DIR/shell/profile.wsl" ".profile"
copy_if_exists "$HOME/.zshrc" "$DOTFILES_DIR/shell/zshrc.wsl" ".zshrc"

# Fish config
if [ -d "$HOME/.config/fish" ]; then
    cp -r "$HOME/.config/fish/"* "$DOTFILES_DIR/config/fish/"
    echo "[OK] Fish config -> config/fish/"

    # Fix common fish syntax error (bash eval to fish eval)
    if [ -f "$DOTFILES_DIR/config/fish/config.fish" ]; then
        # Fix brew shellenv syntax for fish
        sed -i 's/eval "\$(\(.*brew shellenv\))"/eval (\1)/g' "$DOTFILES_DIR/config/fish/config.fish"
        echo "[FIX] Fixed brew shellenv syntax in fish config"
    fi
else
    echo "[--] Fish config not found"
fi

# Git config (we'll strip sensitive parts)
if [ -f "$HOME/.gitconfig" ]; then
    cp "$HOME/.gitconfig" "$DOTFILES_DIR/git/gitconfig.wsl"
    echo "[OK] .gitconfig -> git/gitconfig.wsl"
fi

# SSH config (NOT keys!)
if [ -f "$HOME/.ssh/config" ]; then
    mkdir -p "$DOTFILES_DIR/ssh"
    cp "$HOME/.ssh/config" "$DOTFILES_DIR/ssh/config"
    echo "[OK] SSH config -> ssh/config"
    echo "     (Remember: NEVER commit private keys)"
fi

# Scripts
if [ -d "$HOME/scripts" ]; then
    cp -r "$HOME/scripts/"* "$DOTFILES_DIR/scripts/" 2>/dev/null || true
    echo "[OK] ~/scripts -> scripts/"
fi

# Vim/Neovim
copy_if_exists "$HOME/.vimrc" "$DOTFILES_DIR/vim/vimrc.wsl" ".vimrc"
if [ -d "$HOME/.config/nvim" ]; then
    mkdir -p "$DOTFILES_DIR/config/nvim"
    cp -r "$HOME/.config/nvim/"* "$DOTFILES_DIR/config/nvim/"
    echo "[OK] Neovim config -> config/nvim/"
fi

# Starship prompt
copy_if_exists "$HOME/.config/starship.toml" "$DOTFILES_DIR/config/starship.toml" "Starship config"

# tmux
copy_if_exists "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux.conf" ".tmux.conf"

echo ""
echo "=== Collected files ==="
find "$DOTFILES_DIR" -type f -newer "$DOTFILES_DIR/README.md" 2>/dev/null | head -30

echo ""
echo "=== Git status ==="
cd "$DOTFILES_DIR"
git status --short

echo ""
echo "=== Next steps ==="
echo "1. Review the files: git diff"
echo "2. Add them: git add ."
echo "3. Commit: git commit -m 'Add WSL configs from P15'"
echo "4. Push: git push"
echo ""
echo "Also fix your local fish config:"
echo "  nano ~/.config/fish/config.fish"
echo "  Change: eval \"\\\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
echo "  To:     eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
