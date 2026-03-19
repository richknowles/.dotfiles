#!/usr/bin/env bash
DOCK_FLAG="/tmp/dock-running"

if [ -f "$DOCK_FLAG" ]; then
    pkill -f "nwg-dock-hyprland -i"
    rm -f "$DOCK_FLAG"
else
    cd /home/rich/.config/nwg-dock-hyprland
    touch "$DOCK_FLAG"
    nohup nwg-dock-hyprland -i 32 -w 5 -mb 10 -x -s themes/glass/style.css -c /home/rich/.config/hypr/scripts/launcher.sh > /dev/null 2>&1 &
fi
