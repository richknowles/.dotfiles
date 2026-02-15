#!/bin/bash
# Show all windows - Mac Expose style using wofi

# Get all windows and display in wofi
CLIENTS=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | "\(.title) | \(.class)"' | head -20)

if [ -z "$CLIENTS" ]; then
    exit 1
fi

SELECTION=$(echo "$CLIENTS" | wofi --show dmenu --prompt "Windows" -W 600 -H 400)

if [ -n "$SELECTION" ]; then
    WINDOW_TITLE=$(echo "$SELECTION" | cut -d'|' -f1 | xargs)
    hyprctl dispatch focuswindow title:"$WINDOW_TITLE"
fi
