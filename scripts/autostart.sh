#!/bin/sh

# dwm autostart script
# Place in ~/.local/share/dwm/autostart.sh

# Kill existing instances
killall -q slstatus

# Wait for processes to close
while pgrep -x slstatus >/dev/null; do sleep 1; done

# Start slstatus
slstatus &

# Set wallpaper (keybinds wallpaper is default, fallback to default.jpg)
if [ -f ~/.local/share/wallpapers/keybinds.png ]; then
    xwallpaper --zoom ~/.local/share/wallpapers/keybinds.png 2>/dev/null &
elif [ -f ~/.local/share/wallpapers/default.jpg ]; then
    xwallpaper --zoom ~/.local/share/wallpapers/default.jpg 2>/dev/null &
fi

# Start compositor for transparency (uncomment if needed)
# picom &
