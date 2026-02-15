#!/bin/bash
# Collect CachyOS / ML4W / Hyprland configs for dotfiles repo
# Run this from your ~/.dotfiles directory

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

echo "=== CachyOS Config Collector ==="
echo "Dotfiles dir: $DOTFILES_DIR"
echo ""

# Create directories
mkdir -p "$DOTFILES_DIR/config/hypr"
mkdir -p "$DOTFILES_DIR/config/waybar"
mkdir -p "$DOTFILES_DIR/config/ml4w"
mkdir -p "$DOTFILES_DIR/config/kitty"
mkdir -p "$DOTFILES_DIR/config/fish"
mkdir -p "$DOTFILES_DIR/config/btop"
mkdir -p "$DOTFILES_DIR/config/alacritty"
mkdir -p "$DOTFILES_DIR/linux"

copy_if_exists() {
    src="$1"
    dest="$2"
    name="$3"
    if [ -e "$src" ]; then
        cp -r "$src" "$dest"
        echo "[OK] $name"
    else
        echo "[--] $name not found"
    fi
}

# ============================================================
# Hyprland
# ============================================================
echo ""
echo "--- Hyprland ---"
if [ -d "$HOME/.config/hypr" ]; then
    cp -r "$HOME/.config/hypr/"* "$DOTFILES_DIR/config/hypr/"
    echo "[OK] Hyprland config (full)"
fi

# ============================================================
# Waybar
# ============================================================
echo ""
echo "--- Waybar ---"
if [ -d "$HOME/.config/waybar" ]; then
    cp -r "$HOME/.config/waybar/"* "$DOTFILES_DIR/config/waybar/"
    echo "[OK] Waybar config (full)"
fi

# ============================================================
# ML4W
# ============================================================
echo ""
echo "--- ML4W ---"
if [ -d "$HOME/.config/ml4w" ]; then
    cp -r "$HOME/.config/ml4w/"* "$DOTFILES_DIR/config/ml4w/"
    echo "[OK] ML4W config (full)"
fi

# ============================================================
# Kitty
# ============================================================
echo ""
echo "--- Kitty ---"
if [ -d "$HOME/.config/kitty" ]; then
    cp -r "$HOME/.config/kitty/"* "$DOTFILES_DIR/config/kitty/"
    echo "[OK] Kitty config"
fi

# ============================================================
# Fish shell
# ============================================================
echo ""
echo "--- Fish ---"
if [ -d "$HOME/.config/fish" ]; then
    cp -r "$HOME/.config/fish/"* "$DOTFILES_DIR/config/fish/"
    echo "[OK] Fish config"
fi

# ============================================================
# Alacritty (backup terminal)
# ============================================================
echo ""
echo "--- Alacritty ---"
copy_if_exists "$HOME/.config/alacritty" "$DOTFILES_DIR/config/alacritty" "Alacritty config"

# ============================================================
# btop
# ============================================================
echo ""
echo "--- btop ---"
copy_if_exists "$HOME/.config/btop/btop.conf" "$DOTFILES_DIR/config/btop/btop.conf" "btop config"

# ============================================================
# Neofetch / fastfetch
# ============================================================
echo ""
echo "--- Fetch tools ---"
copy_if_exists "$HOME/.config/neofetch" "$DOTFILES_DIR/config/neofetch" "Neofetch config"
copy_if_exists "$HOME/.config/fastfetch" "$DOTFILES_DIR/config/fastfetch" "Fastfetch config"

# ============================================================
# Git
# ============================================================
echo ""
echo "--- Git ---"
copy_if_exists "$HOME/.gitconfig" "$DOTFILES_DIR/git/gitconfig.cachyos" ".gitconfig"

# ============================================================
# SSH config (NOT keys!)
# ============================================================
echo ""
echo "--- SSH ---"
if [ -f "$HOME/.ssh/config" ]; then
    mkdir -p "$DOTFILES_DIR/ssh"
    cp "$HOME/.ssh/config" "$DOTFILES_DIR/ssh/config.cachyos"
    echo "[OK] SSH config (NOT keys)"
else
    echo "[--] SSH config not found"
fi

# ============================================================
# Package list
# ============================================================
echo ""
echo "--- Packages ---"
pacman -Qe > "$DOTFILES_DIR/linux/packages-cachyos.txt" 2>/dev/null && \
    echo "[OK] Package list ($(wc -l < "$DOTFILES_DIR/linux/packages-cachyos.txt") packages)" || \
    echo "[--] Could not get package list"

# AUR packages
pacman -Qm > "$DOTFILES_DIR/linux/packages-aur.txt" 2>/dev/null && \
    echo "[OK] AUR package list ($(wc -l < "$DOTFILES_DIR/linux/packages-aur.txt") packages)" || \
    echo "[--] Could not get AUR package list"

# ============================================================
# ZFS info
# ============================================================
echo ""
echo "--- ZFS ---"
if command -v zpool &>/dev/null; then
    zpool list > "$DOTFILES_DIR/linux/zfs-pools.txt" 2>/dev/null
    zpool status >> "$DOTFILES_DIR/linux/zfs-pools.txt" 2>/dev/null
    zfs list > "$DOTFILES_DIR/linux/zfs-datasets.txt" 2>/dev/null
    echo "[OK] ZFS pool/dataset info saved"
else
    echo "[--] ZFS not found"
fi

# ============================================================
# Systemd user services
# ============================================================
echo ""
echo "--- Systemd user services ---"
systemctl --user list-unit-files --state=enabled > "$DOTFILES_DIR/linux/systemd-user-enabled.txt" 2>/dev/null && \
    echo "[OK] Enabled user services" || \
    echo "[--] Could not list user services"

# ============================================================
# KVM/libvirt VM list
# ============================================================
echo ""
echo "--- VMs ---"
if command -v virsh &>/dev/null; then
    virsh list --all > "$DOTFILES_DIR/linux/kvm-vms.txt" 2>/dev/null
    echo "[OK] VM list saved"
else
    echo "[--] libvirt not found"
fi

echo ""
echo "=== Collection Complete ==="
echo ""
echo "Files saved to: $DOTFILES_DIR"
echo ""

# Show what's ready to commit
cd "$DOTFILES_DIR"
git status --short | head -30
CHANGES=$(git status --short | wc -l)
echo ""
echo "$CHANGES files changed/added"
echo ""
echo "Next steps:"
echo "  cd ~/.dotfiles"
echo "  git add ."
echo "  git status    # review!"
echo "  git commit -m 'Add CachyOS/ML4W/Hyprland configs from P15'"
echo "  git push"
