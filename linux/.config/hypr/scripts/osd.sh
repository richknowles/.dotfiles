#!/bin/bash
# OSD Helper - shows notifications for volume, brightness, mic

case "$1" in
    volume)
        VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
        MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c "MUTED")
        if [ "$MUTED" -eq 1 ]; then
            notify-send -h int:value:0 -h string:x-canonical-private-synchronous:volume "Volume" "Muted" -t 1000 -u low
        else
            notify-send -h int:value:$VOL -h string:x-canonical-private-synchronous:volume "Volume" "$VOL%" -t 1000 -u low
        fi
        ;;
    brightness)
        BRIGHT=$(brightnessctl -q | grep -oP '\(\K[0-9]+(?=%\))')
        notify-send -h int:value:$BRIGHT -h string:x-canonical-private-synchronous:brightness "Brightness" "$BRIGHT%" -t 1000 -u low
        ;;
    mic)
        MUTED=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -c "yes")
        if [ "$MUTED" -eq 1 ]; then
            notify-send "Microphone" "Muted" -t 1000 -u low
        else
            notify-send "Microphone" "Unmuted" -t 1000 -u low
        fi
        ;;
esac
