#!/bin/bash
# Kill existing waybar
killall waybar 2>/dev/null
sleep 1

# Start waybar with high priority
exec nice -n -5 /usr/bin/waybar -c ~/.config/waybar/themes/azucar-fantastico/config -s ~/.config/waybar/themes/azucar-fantastico/default/style.css
