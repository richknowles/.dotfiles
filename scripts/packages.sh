#!/bin/bash
# Package tracking script for .dotfiles
# Usage: ./packages.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/../packages"

mkdir -p "$PACKAGES_DIR"

echo "=== Saving package lists ==="

echo "→ Pacman packages..."
pacman -Qq | grep -v "$(pacman -Qmq)" > "$PACKAGES_DIR/pacman.txt"

echo "→ AUR packages..."
pacman -Qmq > "$PACKAGES_DIR/aur.txt"

echo "→ Flatpak apps..."
flatpak list --app --columns=application 2>/dev/null > "$PACKAGES_DIR/flatpak.txt"

echo ""
echo "=== Package counts ==="
echo "Pacman: $(wc -l < "$PACKAGES_DIR/pacman.txt") packages"
echo "AUR: $(wc -l < "$PACKAGES_DIR/aur.txt") packages"
echo "Flatpak: $(wc -l < "$PACKAGES_DIR/flatpak.txt") apps"

echo ""
echo "Done! Lists saved to packages/"
