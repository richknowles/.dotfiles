#!/bin/bash

notify-send "Window Info" "Opening..."

INFO=$(hyprctl activewindow -j)

if [ -z "$INFO" ]; then
    notify-send "No active window"
    exit 1
fi

CLASS=$(echo "$INFO" | jq -r '.class')
PID=$(echo "$INFO" | jq -r '.pid')
TITLE=$(echo "$INFO" | jq -r '.title' | cut -c1-50)

notify-send "Window: $CLASS" "PID: $PID"
