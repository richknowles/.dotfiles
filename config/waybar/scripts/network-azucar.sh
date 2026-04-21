#!/usr/bin/env bash

# High-DPI Animated Network Monitor with Color Gradiants

HISTORY_FILE="/tmp/waybar_net_history_azucar"
MAX_HISTORY=30

get_spark() {
    local speed=$1
    local max=524288  # 512KB - higher = more sensitive
    
    if [ $speed -lt 256 ]; then
        echo "░"
        return
    fi
    
    local level=$((speed * 20 / max))
    if [ $level -gt 20 ]; then
        level=20
    fi
    
    case $level in
        0) echo "░" ;;
        1) echo "▁" ;;
        2) echo "▂" ;;
        3) echo "▃" ;;
        4) echo "▄" ;;
        5) echo "▅" ;;
        6) echo "▆" ;;
        7) echo "▇" ;;
        8) echo "█" ;;
        9) echo "█▁" ;;
        10) echo "█▂" ;;
        11) echo "█▃" ;;
        12) echo "█▄" ;;
        13) echo "█▅" ;;
        14) echo "█▆" ;;
        15) echo "█▇" ;;
        16) echo "██" ;;
        17) echo "██▁" ;;
        18) echo "██▂" ;;
        19) echo "██▃" ;;
        20) echo "███" ;;
        *) echo "░" ;;
    esac
}

# Get primary interface
IFACE=$(ip route | grep default | awk '{print $5}' | head -1)

if [ -z "$IFACE" ]; then
    echo '{"text": "📭", "tooltip": "No network"}'
    exit 0
fi

# Get current stats
CURR_RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
CURR_TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)

# Get previous
if [ -f /tmp/waybar_net_prev ]; then
    read PREV_RX PREV_TX < /tmp/waybar_net_prev
else
    PREV_RX=$CURR_RX
    PREV_TX=$CURR_TX
fi

# Calculate diff
RX_DIFF=$((CURR_RX - PREV_RX))
TX_DIFF=$((CURR_TX - PREV_TX))

# Save current
echo "$CURR_RX $CURR_TX" > /tmp/waybar_net_prev

# Update history
echo "$RX_DIFF $TX_DIFF" >> "$HISTORY_FILE"
tail -$MAX_HISTORY "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"

# Format speed
format_speed() {
    local b=$1
    if [ $b -lt 1024 ]; then
        echo "${b}B"
    elif [ $b -lt 1048576 ]; then
        echo "$((b / 1024))K"
    else
        echo "$((b / 1048576)).$(((b % 1048576) / 104857))M"
    fi
}

# Get network name
NET_NAME=$(cat /sys/class/net/$IFACE/operstate 2>/dev/null | tr '[:lower:]' '[:upper:]')

# Create colored sparklines with animation frames
DOWN=""
UP=""
count=0

while read rx tx; do
    # Different colors for different activity levels
    if [ $rx -lt 1024 ]; then
        rcolor="#6272a4"      # Muted blue - idle
    elif [ $rx -lt 10240 ]; then
        rcolor="#8be9fd"     # Cyan - light
    elif [ $rx -lt 102400 ]; then
        rcolor="#50fa7b"     # Green - moderate
    elif [ $rx -lt 524288 ]; then
        rcolor="#ffb86c"     # Orange - heavy
    else
        rcolor="#ff5555"     # Red - extreme
    fi
    
    if [ $tx -lt 512 ]; then
        tcolor="#6272a4"
    elif [ $tx -lt 5120 ]; then
        tcolor="#ff79c6"     # Pink
    elif [ $tx -lt 51200 ]; then
        tcolor="#bd93f9"     # Purple
    elif [ $tx -lt 262144 ]; then
        tcolor="#ffb86c"
    else
        tcolor="#ff5555"
    fi
    
    DOWN="${DOWN}<span color='${rcolor}'>$(get_spark $rx)</span>"
    UP="${UP}<span color='${tcolor}'>$(get_spark $tx)</span>"
    count=$((count + 1))
done < "$HISTORY_FILE"

# Speed indicators
RX_SPEED=$(format_speed $RX_DIFF)
TX_SPEED=$(format_speed $TX_DIFF)

# Generate final output
cat << EOF
{"text": "⬇<span color='#ff5555'>${DOWN}</span> ⬆<span color='#bd93f9'>${UP}</span>", "tooltip": "⬇ ${RX_SPEED}/s  ⬆ ${TX_SPEED}/s\nInterface: ${IFACE}\nStatus: ${NET_NAME}"}
EOF