#!/bin/bash
# 🏴‍☠️ Captain's Treasure Map - Richard's Big Pickle Edition 🦜

TIME=$(date '+%H:%M')
DATE=$(date '+%b %d')
YEAR=$(date '+%Y')

# System stats
CPU=$(cat /proc/loadavg | awk '{print int($1)}')
RAM=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2*100}')
VOL=$(amixer -D pulse get Master | grep 'Left:' | awk -F'[' '{print $2}' | awk -F'%' '{print $1}')
BAT=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100)

# Network activity
NET_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
if [ -n "$NET_IFACE" ]; then
    RX=$(cat /sys/class/net/$NET_IFACE/statistics/rx_bytes 2>/dev/null | head -c 3)
    TX=$(cat /sys/class/net/$NET_IFACE/statistics/tx_bytes 2>/dev/null | head -c 3)
    NET="📡⬇${RX} ⬆${TX}"
else
    NET="⚓ Adrift"
fi

# Mood based on CPU (captain's mood!)
case $CPU in
    0) MOOD="🌊 Calm Seas" ;;
    1) MOOD="🎵 Sea Shanty" ;;
    2) MOOD="💰 Plunderin'" ;;
    3) MOOD="⚔️ Battle Stations" ;;
    *) MOOD="🧭 Chartin' Course" ;;
esac

# The pickle factor! 🥒
PICKLE_ASCII="🥒"

# Output - Rich's Big Pickle pride!
echo "{\"text\": \"$PICKLE_ASCII $MOOD | $NET | 💾${RAM}% | 🔊${VOL}% | 🔋${BAT}% | ⏰$TIME\", \"tooltip\": \"🏴‍☠️ CAPTAIN'S TREASURE MAP 🦜\\n═══════════════════════\\n🥒 Richard's Big Pickle\\n═══════════════════════\\n⛵ Mood: $MOOD\\n💾 RAM: $RAM%\\n🔊 Vol: $VOL%\\n🔋 Bat: $BAT%\\n📡 Net: $NET\\n═══════════════════════\\n⏰ $DATE $YEAR\"}"