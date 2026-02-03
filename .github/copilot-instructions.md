# Copilot Instructions for wm

## Project Overview

Suckless window manager setup with **Tokyo Night** theme for **Arch Linux**.

## Architecture

```
dwm/                       # Main folder (clone this repo as 'dwm')
├── install.sh             # Automated installer
├── README.md              # Documentation
├── dwm-flexipatch/        # Window manager
│   ├── patches.h          # Enabled patches (copied from patches.def.h, then modified)
│   ├── config.h           # Theme, keybinds, rules (copied from config.def.h, then modified)
│   └── config.mk          # Build config (XRENDER enabled for alpha)
├── dmenu-flexipatch/      # Launcher
│   ├── patches.h          # Enabled patches
│   ├── config.h           # Centered, fuzzy search
│   └── config.mk          # Build config (XRENDER enabled)
├── st-flexipatch/         # Terminal
│   ├── patches.h          # Enabled patches (ALPHA, ANYSIZE, SCROLLBACK, etc.)
│   ├── config.h           # Tokyo Night colors, 95% opacity
│   └── config.mk          # Build config (XRENDER enabled for alpha)
├── slstatus/              # Status bar
│   └── config.h           # CPU, RAM, disk, date, time
├── slock/                 # Screen locker
│   └── config.h           # Lock colors
└── scripts/
    └── autostart.sh       # Starts slstatus
```

## Enabled Patches

### dwm-flexipatch
- `BAR_ALPHA_PATCH` - Transparent bar
- `VANITYGAPS_PATCH` - Gaps between windows
- `ALWAYSCENTER_PATCH` - Center floating windows
- `ATTACHBOTTOM_PATCH` - New windows at bottom
- `AUTOSTART_PATCH` - Run autostart.sh
- `PERTAG_PATCH` - Per-tag layouts

### dmenu-flexipatch
- `ALPHA_PATCH` - Transparency
- `CENTER_PATCH` - Centered on screen
- `FUZZYMATCH_PATCH` - Fuzzy search
- `CASEINSENSITIVE_PATCH` - Case insensitive
- `BORDER_PATCH` - Border around menu
- `LINE_HEIGHT_PATCH` - Custom line height

### st-flexipatch
- `ALPHA_PATCH` - Transparency (95%)
- `ANYSIZE_PATCH` - Eliminates ugly padding
- `BOXDRAW_PATCH` - Better box drawing
- `CLIPBOARD_PATCH` - Ctrl+Shift+C/V
- `SCROLLBACK_PATCH` - Scrollback buffer
- `SCROLLBACK_MOUSE_PATCH` - Mouse scroll

## Key Design Decisions

- **Floating windows**: Always centered via `ALWAYSCENTER_PATCH`
- **Terminal padding**: 16px border for better aesthetics
- **Layout symbols**: `[T]` tiled, `[F]` floating, `[M]` monocle
- **Gaps**: 10px all around
- **Bar opacity**: 95% (0xf2)
- **Terminal opacity**: 95%
- **New windows**: Attach at bottom

## Color Scheme (Tokyo Night)

- Background: `#1a1b26`
- Foreground: `#c0caf5`
- Blue: `#7aa2f7`
- Purple: `#bb9af7`
- Green: `#9ece6a`
- Yellow: `#e0af68`
- Orange: `#ff9e64`
- Red: `#f7768e`

## Build Commands (Arch)

```bash
# Quick install (run from dwm folder)
./install.sh

# Manual build
sudo pacman -S --needed base-devel git xorg-server xorg-xinit libx11 libxft libxinerama libxrender ttf-jetbrains-mono-nerd

cd dwm-flexipatch && sudo make clean install
cd ../dmenu-flexipatch && sudo make clean install
cd ../st-flexipatch && sudo make clean install
cd ../slstatus && sudo make clean install
cd ../slock && sudo make clean install
```

## Key Keybindings

| Key | Action |
|-----|--------|
| `Mod+Return` | Terminal (st) |
| `Mod+p` | dmenu |
| `Mod+Shift+c` | Close window |
| `Mod+Ctrl+l` | Lock screen (slock) |
| `Mod+t/f/m` | Tiled/Floating/Monocle |
| `Mod+Shift+q` | Quit dwm |
