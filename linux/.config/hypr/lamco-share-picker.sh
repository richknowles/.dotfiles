#!/bin/bash
# Auto-accept share picker for Lamco RDP Server
# Conforms to hyprland-share-picker stdout selection layout
# Always selects the first available screen

# Get primary monitor name from hyprctl
SCREEN=$(hyprctl monitors -j 2>/dev/null | python3 -c "
import sys, json
try:
    monitors = json.load(sys.stdin)
    if monitors:
        print(monitors[0]['name'])
    else:
        print('')
except:
    print('')
")

if [ -z "$SCREEN" ]; then
    # Fallback: try to find any output
    SCREEN=$(hyprctl monitors 2>/dev/null | grep -oP 'Monitor \K\S+' | head -1)
fi

if [ -z "$SCREEN" ]; then
    # Last resort
    SCREEN="eDP-1"
fi

# Output the same format as hyprland-share-picker when a screen is clicked
# "[SELECTION]r/screen:NAME" with trailing newline
# The "r" means "allow restore token" is checked
printf '[SELECTION]r/screen:%s\n' "$SCREEN"
