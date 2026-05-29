#!/usr/bin/env bash
API="http://localhost:52900"
MOUNTS=$(curl -s -X POST "$API/mount/listmounts" 2>/dev/null)
COUNT=$(echo "$MOUNTS" | jq '.mountPoints | length' 2>/dev/null || echo 0)

if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    TOOLTIP=$(echo "$MOUNTS" | jq -r '.mountPoints[] | "\(.Fs)  →  \(.MountPoint)"' 2>/dev/null | paste -sd '\n')
    echo "{\"text\": \" $COUNT\", \"tooltip\": \"$TOOLTIP\", \"class\": \"connected\"}"
else
    echo "{\"text\": \" 0\", \"tooltip\": \"No rclone mounts active\", \"class\": \"disconnected\"}"
fi
