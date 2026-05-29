#!/usr/bin/env bash
# Hermes AI Gateway status for Waybar
# Checks actual gateway process + Telegram API connectivity
# Returns JSON with class "up" or "down" for CSS icon coloring

CACHE_FILE="/tmp/hermes-status.cache"
LAST_STATE_FILE="/tmp/hermes-status-last.txt"

# Check if gateway process is running
PID=$(pgrep -f "hermes.*gateway.run" | head -1)
if [ -z "$PID" ]; then
  echo '{"text": "\u00b7", "class": "down", "tooltip": "Hermes Gateway: Stopped\nLeft-click: Status\nRight-click: Menu"}'
  echo "down" > "$LAST_STATE_FILE"
  rm -f "$CACHE_FILE"
  exit 0
fi

# Gather process info
UPTIME=$(ps -o etime= -p "$PID" 2>/dev/null | xargs)
MEM=$(ps -o rss= -p "$PID" 2>/dev/null | xargs)
if [ -n "$MEM" ]; then
  MEM_MB=$((MEM / 1024))
else
  MEM_MB="?"
fi

# Check Telegram bot connectivity via API
BOT_TOKEN=$(grep TELEGRAM_BOT_TOKEN "$HOME/.hermes/.env" 2>/dev/null | cut -d= -f2)
TG_STATUS="unknown"
TG_BOT_NAME=""
if [ -n "$BOT_TOKEN" ]; then
  if [ -f "$CACHE_FILE" ] && [ "$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null)))" -lt 30 ]; then
    TG_STATUS=$(head -1 "$CACHE_FILE")
    TG_BOT_NAME=$(tail -1 "$CACHE_FILE" 2>/dev/null)
  else
    API_RESP=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getMe" 2>/dev/null)
    TG_STATUS=$(echo "$API_RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); print(200 if d.get('ok') else d.get('error_code',999))" 2>/dev/null)
    TG_BOT_NAME=$(echo "$API_RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',{}).get('first_name',''))" 2>/dev/null)
    printf "%s\n%s" "$TG_STATUS" "$TG_BOT_NAME" > "$CACHE_FILE"
  fi
fi

# Determine class and tooltip
if [ "$TG_STATUS" = "200" ]; then
  CLASS="up"
  TOOLTIP="Hermes: Online\nBot: ${TG_BOT_NAME:-Yana}\nPID: $PID\nUptime: $UPTIME\nMem: ${MEM_MB}MB\n\nLeft-click: Status  |  Right-click: Menu"
elif [ "$TG_STATUS" = "unknown" ]; then
  CLASS="up"
  TOOLTIP="Hermes: Online (no Telegram)\nPID: $PID\nUptime: $UPTIME\n\nLeft-click: Status  |  Right-click: Menu"
else
  CLASS="degraded"
  TOOLTIP="Hermes: Degraded (Telegram ✗)\nPID: $PID\nUptime: $UPTIME\nAPI: HTTP $TG_STATUS\n\nLeft-click: Status  |  Right-click: Menu"
fi

# Send notification on state change
if [ -f "$LAST_STATE_FILE" ]; then
  LAST_STATE=$(cat "$LAST_STATE_FILE")
  if [ "$LAST_STATE" != "$CLASS" ]; then
    case "$CLASS" in
      up) notify-send "Hermes Gateway" "Online ✓  Bot: ${TG_BOT_NAME:-connected}" -i dialog-information -t 3000 ;;
      degraded) notify-send "Hermes Gateway" "Telegram disconnected ⚠" -i dialog-warning -t 5000 ;;
      down) notify-send "Hermes Gateway" "Stopped ✗" -i dialog-error -t 5000 ;;
    esac
  fi
fi
echo "$CLASS" > "$LAST_STATE_FILE"

echo "{\"text\": \"\u00b7\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
