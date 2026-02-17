#!/bin/bash
# Install packages from saved lists
# Usage: ./install-packages.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/../packages"

echo "=== Installing packages ==="

# Pacman
if [ -f "$PACKAGES_DIR/pacman.txt" ]; then
    echo "→ Installing Pacman packages..."
    yay -S --needed - < "$PACKAGES_DIR/pacman.txt"
fi

# AUR
if [ -f "$PACKAGES_DIR/aur.txt" ]; then
    echo "→ Installing AUR packages..."
    yay -S --needed - < "$PACKAGES_DIR/aur.txt"
fi

# Flatpak
if [ -f "$PACKAGES_DIR/flatpak.txt" ]; then
    echo "→ Installing Flatpak apps..."
    while IFS= read -r app; do
        flatpak install -y "$app" 2>/dev/null || true
    done < "$PACKAGES_DIR/flatpak.txt"
fi

echo ""
echo "Done!"
