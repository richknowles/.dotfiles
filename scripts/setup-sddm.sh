#!/bin/bash
# setup-sddm-default.sh - Set Hyprland as default session in SDDM
# Run after installing a new distro with dotfiles restored

echo ":: Configuring SDDM to default to Hyprland..."

sudo mkdir -p /etc/sddm.conf.d

sudo tee /etc/sddm.conf.d/default-session.conf << 'EOF'
[General]
Session=hyprland.desktop
EOF

echo ":: Done! Hyprland will be the default at login."
