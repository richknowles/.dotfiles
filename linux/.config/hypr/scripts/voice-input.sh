#!/bin/bash

# Voice input script using whisper.cpp
# Records audio and converts to text

NOTIFY_ICON="microphone-sensitivity"
AUDIO_FILE="/tmp/voice_input.wav"
OUTPUT_FILE="/tmp/voice_output.txt"

# Check if whisper is installed
if ! command -v whisper &> /dev/null; then
    notify-send -u critical "Whisper" "whisper.cpp not installed. Run: yay -S whisper.cpp"
    exit 1
fi

# Start recording
notify-send -u normal "Voice Input" "Recording... (press ESC to stop)"
ffmpeg -f alsa -i default -t 30 -ar 16000 "$AUDIO_FILE" &
FFMPEG_PID=$!

# Wait for ESC or timeout
read -t 30 -n 1

# Stop recording
kill $FFMPEG_PID 2>/dev/null

if [ -f "$AUDIO_FILE" ]; then
    # Process with whisper
    whisper "$AUDIO_FILE" > "$OUTPUT_FILE" 2>/dev/null
    
    if [ -s "$OUTPUT_FILE" ]; then
        # Copy to clipboard
        xclip -selection clipboard < "$OUTPUT_FILE"
        notify-send -u normal "Voice Input" "Transcribed and copied to clipboard!"
    else
        notify-send -u critical "Voice Input" "No speech detected"
    fi
    
    rm -f "$AUDIO_FILE" "$OUTPUT_FILE"
else
    notify-send -u critical "Voice Input" "Recording failed"
fi
