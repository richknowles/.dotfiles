#!/usr/bin/env bash

# Higher resolution network sparkline

get_spark() {
    local speed=$1
    local max=262144  # Lower = more sensitive
    
    if [ $speed -lt 512 ]; then
        echo "─"
        return
    fi
    
    local level=$((speed * 20 / max))
    if [ $level -gt 20 ]; then
        level=20
    fi
    
    case $level in
        0|1) echo "▁" ;;
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
        *) echo "─" ;;
    esac
}

IFACE=$(ip route | grep default | awk '{print $5}' | head -1)

if [ -z "$IFACE" ]; then
    echo '{"text": "⬇⬆"}'
    exit 0
fi

if [ -f /tmp/waybar_net_stats ]; then
    read PREV_RX PREV_TX < /tmp/waybar_net_stats
else
    PREV_RX=0
    PREV_TX=0
fi

CURR_RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
CURR_TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)

RX_DIFF=$((CURR_RX - PREV_RX))
TX_DIFF=$((CURR_TX - PREV_TX))

echo "$CURR_RX $CURR_TX" > /tmp/waybar_net_stats

# Keep only last 8 readings
echo "$RX_DIFF $TX_DIFF" >> /tmp/waybar_net_history
tail -8 /tmp/waybar_net_history > /tmp/waybar_net_history.tmp
mv /tmp/waybar_net_history.tmp /tmp/waybar_net_history

# Generate sparklines
DOWN=""
UP=""
while read rx tx; do
    DOWN="${DOWN}<span color='#ff5555'>$(get_spark $rx)</span>"
    UP="${UP}<span color='#55aaff'>$(get_spark $tx)</span>"
done < /tmp/waybar_net_history

format_speed() {
    local b=$1
    if [ $b -lt 1024 ]; then
        echo "${b}B"
    elif [ $b -lt 1048576 ]; then
        echo "$((b / 1024))K"
    else
        echo "$((b / 1048576))M"
    fi
}

echo "{\"text\": \"${DOWN} ${UP}\", \"tooltip\": \"↓ $(format_speed $RX_DIFF)  ↑ $(format_speed $TX_DIFF)\"}"
