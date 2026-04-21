#!/bin/bash

# Voice input script using whisper.cpp
# Records audio and converts to text

NOTIFY_ICON="microphone-sensitivity"
AUDIO_FILE="/tmp/voice_input.wav"
OUTPUT_FILE="/tmp/voice_output.txt"

# Check if whisper is installed
MODEL_PATH="/tmp/whisper.cpp/models/for-tests-ggml-tiny.bin"
if [ ! -f "$MODEL_PATH" ]; then
    notify-send -u critical "Whisper" "Model not found at $MODEL_PATH"
    exit 1
fi

# Make sure no existing ffmpeg is running
pkill -f "ffmpeg.*voice_input" 2>/dev/null

# Start recording
notify-send -u normal "Voice Input" "Recording... (speak now, 30 sec max)"
ffmpeg -f alsa -i hw:0 -t 30 -ar 16000 "$AUDIO_FILE" 2>/dev/null &
FFMPEG_PID=$!

# Wait for recording to finish (30 sec timeout) or check if file exists
sleep 30

# Make sure recording is stopped
kill $FFMPEG_PID 2>/dev/null
wait $FFMPEG_PID 2>/dev/null

if [ -f "$AUDIO_FILE" ] && [ -s "$AUDIO_FILE" ]; then
    # Process with whisper (suppress debug output)
    /usr/bin/whisper-cli -m "$MODEL_PATH" -f "$AUDIO_FILE" --no-timestamps -nt 2>/dev/null > "$OUTPUT_FILE"
    
    if [ -s "$OUTPUT_FILE" ]; then
        # Copy to clipboard
        xclip -selection clipboard < "$OUTPUT_FILE"
        notify-send -u normal "Voice Input" "Done! Text copied to clipboard."
    else
        notify-send -u critical "Voice Input" "No speech detected"
    fi
    
    rm -f "$AUDIO_FILE" "$OUTPUT_FILE"
else
    notify-send -u critical "Voice Input" "Recording failed - no audio captured"
fi
