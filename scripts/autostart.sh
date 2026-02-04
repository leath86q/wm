#!/bin/sh

# dwm autostart script
# Place in ~/.local/share/dwm/autostart.sh

# Kill existing instances
killall -q slstatus

# Wait for processes to close
while pgrep -x slstatus >/dev/null; do sleep 1; done

# Start slstatus
slstatus &

# Set wallpaper
xwallpaper --zoom ~/.local/share/wallpapers/wallpaper.jpg 2>/dev/null &

# Start compositor for transparency (uncomment if needed)
# picom &
