#!/bin/bash
# Animated lock screen - plays video in background

# Kill any previous lock screen mpv
pkill -f "mpvpaper.*lock-screen" 2>/dev/null

# Start mpvpaper for lock screen (lower quality for stability)
mpvpaper -f --wid=0 -o "loop mute=yes no-audio" "eDP-1" ~/.wallpapers/starfield_lock.mp4 &

# Small delay
sleep 0.3

# Lock with hyprlock
hyprlock

# When unlocked, kill the lock screen mpv
pkill -f "mpvpaper.*lock-screen" 2>/dev/null
