#!/bin/bash
#
# Generate a 4K wallpaper with DWM keybindings
# Uses ImageMagick with neutral color scheme
#

set -e

# Output settings
OUTPUT_DIR="${HOME}/.local/share/wallpapers"
OUTPUT_FILE="${OUTPUT_DIR}/keybinds.png"
WIDTH=3840
HEIGHT=2160

# Neutral color scheme
BG_COLOR="#1e1e1e"        # Dark charcoal background
TEXT_COLOR="#d4d4d4"      # Light gray text
HEADER_COLOR="#808080"    # Medium gray for headers
ACCENT_COLOR="#6b6b6b"    # Subtle gray accent
BORDER_COLOR="#3d3d3d"    # Dark border

# Font settings (JetBrains Mono if available, fallback to monospace)
FONT="JetBrainsMono-Nerd-Font"
FONT_FALLBACK="DejaVu-Sans-Mono"

# Check if ImageMagick is installed
if ! command -v convert &>/dev/null; then
    echo "Error: ImageMagick is not installed. Install with: sudo pacman -S imagemagick"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check which font is available
if fc-list | grep -qi "JetBrains"; then
    FONT="JetBrainsMono-Nerd-Font"
elif fc-list | grep -qi "DejaVu"; then
    FONT="DejaVu-Sans-Mono"
else
    FONT="monospace"
fi

echo "Generating keybinds wallpaper..."
echo "Using font: $FONT"

# Create the wallpaper with ImageMagick
convert -size ${WIDTH}x${HEIGHT} xc:"${BG_COLOR}" \
    -font "$FONT" \
    \
    -fill "${HEADER_COLOR}" -pointsize 72 \
    -gravity North -annotate +0+80 "DWM KEYBINDINGS" \
    \
    -fill "${ACCENT_COLOR}" -pointsize 28 \
    -gravity North -annotate +0+170 "Super (Mod) + Key" \
    \
    -fill "${TEXT_COLOR}" -pointsize 32 \
    \
    -gravity NorthWest \
    \
    -annotate +200+300 "━━━━━━━━━━  ESSENTIALS  ━━━━━━━━━━" \
    -annotate +200+360 "Mod + Return          Open terminal (st)" \
    -annotate +200+410 "Mod + p               Open dmenu launcher" \
    -annotate +200+460 "Mod + Shift + c       Close focused window" \
    -annotate +200+510 "Mod + Shift + q       Quit dwm" \
    -annotate +200+560 "Mod + Ctrl + l        Lock screen (slock)" \
    \
    -annotate +200+660 "━━━━━━━━━━  NAVIGATION  ━━━━━━━━━━" \
    -annotate +200+720 "Mod + j / k           Focus next/prev window" \
    -annotate +200+770 "Mod + h / l           Shrink/expand master" \
    -annotate +200+820 "Mod + Shift + Return  Promote to master" \
    -annotate +200+870 "Mod + Tab             Toggle last tag" \
    -annotate +200+920 "Mod + 1-9             Switch to tag 1-9" \
    -annotate +200+970 "Mod + Shift + 1-9     Move window to tag" \
    -annotate +200+1020 "Mod + 0               View all tags" \
    -annotate +200+1070 "Mod + comma/period   Focus prev/next monitor" \
    \
    -annotate +200+1170 "━━━━━━━━━━  LAYOUTS  ━━━━━━━━━━" \
    -annotate +200+1230 "Mod + t               Tiled layout [T]" \
    -annotate +200+1280 "Mod + f               Floating layout [F]" \
    -annotate +200+1330 "Mod + m               Monocle layout [M]" \
    -annotate +200+1380 "Mod + space           Toggle layouts" \
    -annotate +200+1430 "Mod + Shift + space   Toggle floating" \
    \
    -gravity NorthEast \
    \
    -annotate +200+300 "━━━━━━━━━━  GAPS (Alt)  ━━━━━━━━━━" \
    -annotate +200+360 "Mod + Alt + u/U       Increase/decrease gaps" \
    -annotate +200+410 "Mod + Alt + 0         Toggle gaps on/off" \
    -annotate +200+460 "Mod + Alt + Shift + 0 Reset gaps to default" \
    -annotate +200+510 "Mod + Alt + i/I       Inner gaps +/-" \
    -annotate +200+560 "Mod + Alt + o/O       Outer gaps +/-" \
    \
    -annotate +200+660 "━━━━━━━━━━  WINDOW MGMT  ━━━━━━━━━━" \
    -annotate +200+720 "Mod + i / d           Inc/dec master count" \
    -annotate +200+770 "Mod + b               Toggle bar" \
    -annotate +200+820 "Mod + Shift + j/k     Move window in stack" \
    -annotate +200+870 "Mod + y               Toggle fullscreen" \
    -annotate +200+920 "Mod + grave (~)       Toggle scratchpad" \
    \
    -annotate +200+1020 "━━━━━━━━━━  MULTI-MONITOR  ━━━━━━━━━━" \
    -annotate +200+1080 "Mod + ,/.             Focus prev/next monitor" \
    -annotate +200+1130 "Mod + Shift + ,/.     Send window to monitor" \
    \
    -annotate +200+1230 "━━━━━━━━━━  MOUSE  ━━━━━━━━━━" \
    -annotate +200+1290 "Mod + Left Click      Move floating window" \
    -annotate +200+1340 "Mod + Right Click     Resize floating window" \
    -annotate +200+1390 "Mod + Middle Click    Toggle floating" \
    \
    -fill "${ACCENT_COLOR}" -pointsize 24 \
    -gravity South -annotate +0+80 "Config: ~/.config/dwm/config.h  |  Reload: Mod+Shift+r  |  Tokyo Night Theme" \
    \
    "${OUTPUT_FILE}"

echo "Wallpaper generated: ${OUTPUT_FILE}"
echo ""
echo "To set as wallpaper:"
echo "  xwallpaper --zoom ${OUTPUT_FILE}"
