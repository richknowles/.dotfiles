#!/usr/bin/env bash

RESUME_FILE="$HOME/.config/opencode/resume_last_session"
SESSION_FILE="$HOME/.config/opencode/last_session_id"

toggle_resume() {
    if [ -f "$RESUME_FILE" ]; then
        rm "$RESUME_FILE"
    else
        touch "$RESUME_FILE"
    fi
}

get_resume_status() {
    [ -f "$RESUME_FILE" ] && echo "checked" || echo "unchecked"
}

case "$1" in
    --toggle-resume)
        toggle_resume
        ;;
    --get-resume)
        get_resume_status
        ;;
    --menu)
        RESUME_STATE=$(get_resume_status)
        SELECTION=$(echo -e "Start Opencode\nStart Claude Code\nResume Last Session [$RESUME_STATE]\n--" | rofi -dmenu -p "AI" -i)

        case "$SELECTION" in
            "Start Opencode")
                opencode &
                ;;
            "Start Claude Code")
                claude &
                ;;
            "Resume Last Session"*)
                toggle_resume
                ;;
        esac
        ;;
    *)
        echo ""
        ;;
esac
