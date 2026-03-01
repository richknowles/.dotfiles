#!/bin/bash
# Lock screen wallpaper with mpv

# Kill any existing lock screen mpv
pkill -f "mpvpaper.*lockscreen" 2>/dev/null

# Start mpvpaper for lock screen on all monitors
mpvpaper -f -o "loop mute=yes lockscreen" * ~/.wallpapers/kerr_blackhole.mp4 &
