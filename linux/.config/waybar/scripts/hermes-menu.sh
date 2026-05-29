#!/usr/bin/env bash
# Hermes right-click menu for Waybar
# Uses wofi for a native Wayland popup menu
# Pass --status for left-click (quick status notification)

HERMES_HOME="$HOME/.hermes"
ENV_FILE="$HERMES_HOME/.env"
BOT_TOKEN=$(grep TELEGRAM_BOT_TOKEN "$ENV_FILE" 2>/dev/null | cut -d= -f2)
ALLOWED_USER=$(grep TELEGRAM_ALLOWED_USERS "$ENV_FILE" 2>/dev/null | cut -d= -f2)

notify() {
  notify-send "Hermes Gateway" "$1" -t 5000
}

# --- Left-click: quick status ---
if [ "${1:-}" = "--status" ]; then
  PID=$(pgrep -f "hermes.*gateway.run" | head -1)
  if [ -z "$PID" ]; then
    notify "Gateway is not running"
    exit 0
  fi
  UPTIME=$(ps -o etime= -p "$PID" 2>/dev/null | xargs)
  MEM=$(ps -o rss= -p "$PID" 2>/dev/null | xargs)
  MEM_MB=$((MEM / 1024))
  TG_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "https://api.telegram.org/bot${BOT_TOKEN}/getMe" 2>/dev/null)
  if [ "$TG_CHECK" = "200" ]; then
    TG_MSG="Telegram: Connected ✓"
  else
    TG_MSG="Telegram: ✗"
  fi
  notify "PID: $PID\nUptime: $UPTIME\nMemory: ${MEM_MB}MB\n$TG_MSG"
  exit 0
fi

# --- Right-click: wofi menu ---

PID=$(pgrep -f "hermes.*gateway.run" | head -1)
if [ -n "$PID" ]; then
  UPTIME=$(ps -o etime= -p "$PID" 2>/dev/null | xargs)
  STATUS_ICON="🟢"
  STATUS_LABEL="Running ($UPTIME)"
else
  STATUS_ICON="🔴"
  STATUS_LABEL="Stopped"
fi

MENU_ITEMS="$STATUS_ICON  $STATUS_LABEL
📋  Gateway Status
🔄  Restart Gateway
⏹  Stop Gateway
📨  Send Test Message
📜  View Logs
💬  Open Hermes Chat
🆕  Check for Updates
🥪  Make Me A Sandwich
👉  Poke Me"

SELECTION=$(echo "$MENU_ITEMS" | wofi --show dmenu \
  --prompt "Hermes Gateway" \
  --width 320 \
  --height 380 \
  --location top_right \
  --x 10 \
  --y 46 \
  --insensitive \
  --cache-file /dev/null 2>/dev/null)

[ -z "$SELECTION" ] && exit 0

ACTION=$(echo "$SELECTION" | sed 's/^[^a-zA-Z]*//')

case "$ACTION" in
  "Gateway Status"|"Running"*|"Stopped"*)
    if [ -n "$PID" ]; then
      MEM=$(ps -o rss= -p "$PID" 2>/dev/null | xargs)
      MEM_MB=$((MEM / 1024))
      TG_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "https://api.telegram.org/bot${BOT_TOKEN}/getMe" 2>/dev/null)
      if [ "$TG_CHECK" = "200" ]; then
        TG_MSG="Telegram: Connected ✓"
      else
        TG_MSG="Telegram: ✗ (HTTP $TG_CHECK)"
      fi
      STATUS_MSG="PID: $PID\nUptime: $UPTIME\nMemory: ${MEM_MB}MB\n$TG_MSG"
    else
      STATUS_MSG="Gateway is not running"
    fi
    notify "$STATUS_MSG"
    ;;

  "Restart Gateway")
    systemctl --user restart hermes-gateway.service
    sleep 2
    if pgrep -f "hermes.*gateway.run" > /dev/null 2>&1; then
      notify "Gateway restarted ✓"
    else
      notify "Gateway restart failed ✗"
    fi
    ;;

  "Stop Gateway")
    systemctl --user stop hermes-gateway.service
    notify "Gateway stopped"
    ;;

  "Send Test Message")
    if [ -z "$BOT_TOKEN" ] || [ -z "$ALLOWED_USER" ]; then
      notify "Telegram not configured — missing BOT_TOKEN or ALLOWED_USERS"
      exit 1
    fi
    RESULT=$(curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
      -d "chat_id=${ALLOWED_USER}&text=🧪 Test message from Hermes menu $(date '+%H:%M')" 2>&1)
    if echo "$RESULT" | python3 -c "import sys,json; sys.exit(0 if json.load(sys.stdin).get('ok') else 1)" 2>/dev/null; then
      notify "Test message sent ✓"
    else
      notify "Test message failed ✗"
    fi
    ;;

  "View Logs")
    LOGS=$(journalctl --user -u hermes-gateway --since "1 hour ago" --no-pager -n 30 2>&1 | tail -20)
    notify "$LOGS"
    ;;

  "Open Hermes Chat")
    kitty --title "Hermes Chat" -e hermes chat &
    ;;

  "Check for Updates")
    UPDATES=$(hermes update --check 2>&1)
    notify "$UPDATES"
    ;;

  "Make Me A Sandwich")
    notify "What do you think I am, a sandwich shop? ... 🥪\n\n...Okay fine.\nBread. Butter. Cheese.\nGrilled.\n\nThere's your damn sandwich."
    ;;

  "Poke Me")
    notify "👉 ... I felt that.\n\nYou're brave. I like it, Captain."
    ;;

  *)
    notify "Unknown option: $ACTION"
    ;;
esac
