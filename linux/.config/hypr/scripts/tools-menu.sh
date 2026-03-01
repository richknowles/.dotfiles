#!/bin/bash
# Tools menu for waybar - dropdown style

OPTIONS="gpick
opencode
Firefox
VS Code
Settings
System Monitor (btop)
File Manager
Terminal
Bluetooth
Network
Virt Manager
Google Earth
Proton VPN"

CHOICE=$(echo "$OPTIONS" | wofi --dmenu --prompt "Tools" --show)

case "$CHOICE" in
    gpick)
        gpick -p -s &
        ;;
    opencode)
        alacritty -e opencode &
        ;;
    Firefox)
        firefox &
        ;;
    "VS Code")
        code &
        ;;
    Settings)
        flatpak run com.ml4w.hyprlandsettings &
        ;;
    "System Monitor (btop)")
        alacritty -e btop &
        ;;
    "File Manager")
        nautilus &
        ;;
    Terminal)
        alacritty &
        ;;
    Bluetooth)
        blueman-manager &
        ;;
    Network)
        nm-connection-editor &
        ;;
    "Virt Manager")
        virt-manager &
        ;;
    "Google Earth")
        QT_QPA_PLATFORM=xcb google-earth-pro &
        ;;
    "Proton VPN")
        proton-vpn &
        ;;
esac
