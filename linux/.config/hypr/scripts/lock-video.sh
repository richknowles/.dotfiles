#!/bin/bash

# Captain-Fantastic Video Lock Screen Script
# Ctrl+Alt+L: Creates 99, locks, then on unlock destroys 99 and returns to original

VIDEO_WS=99

# Save current workspace
ORIG_WS=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id // 1')
echo "Original: $ORIG_WS"

# Switch to workspace 99
hyprctl dispatch workspace $VIDEO_WS
sleep 0.5

# Lock
hyprlock

# Wait for unlock - this blocks until user enters password
while pgrep -x hyprlock > /dev/null; do
    sleep 0.5
done

echo "Unlocked! Cleaning up..."

# Switch away from 99 (this should remove it since it's empty)
hyprctl dispatch workspace $ORIG_WS
sleep 0.3

# Return to original workspace
hyprctl dispatch workspace $ORIG_WS
echo "Done - back to workspace $ORIG_WS"
