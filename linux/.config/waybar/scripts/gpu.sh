#!/bin/bash

# Query NVIDIA stats: Utilization, Memory Used, and Temp
stats=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,temperature.gpu --format=csv,noheader,nounits 2>/dev/null)

# Check if nvidia-smi failed (e.g., driver issues)
if [ $? -ne 0 ]; then
    echo "{\"text\":\"󰾲 ERR\", \"tooltip\":\"NVIDIA Driver Not Found\"}"
    exit 1
fi

util=$(echo $stats | cut -d',' -f1 | tr -d ' ')
mem=$(echo $stats | cut -d',' -f2 | tr -d ' ')
temp=$(echo $stats | cut -d',' -f3 | tr -d ' ')

# Set icon based on load
if [ "$util" -gt 80 ]; then icon="󰾲"; elif [ "$util" -gt 30 ]; then icon="󰾵"; else icon="󰾳"; fi

# Output JSON for Waybar
# text: what shows on the bar
# tooltip: what shows on hover
echo "{\"text\":\"$icon $util%\", \"tooltip\":\"GPU Load: $util%\nMemory: ${mem}MiB\nTemp: $temp°C\", \"class\":\"gpu-module\"}"
