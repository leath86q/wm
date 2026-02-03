# DWM - Suckless Window Manager Setup

A minimal suckless desktop environment with **Tokyo Night** theme for **Arch Linux**.

## Features

- 🎨 **Tokyo Night** color scheme across all components
- 📊 **slstatus** bar: CPU, RAM, disk, date, time
- 🪟 **Vanity gaps** (10px) with toggle
- 🔲 **Centered floating windows**
- 📝 **Layout indicators**: `[T]` tiled, `[F]` floating, `[M]` monocle
- 🔤 **JetBrains Mono Nerd Font**
- 🔍 **Fuzzy search** in dmenu
- 🖥️ **Transparent** bar and terminal (95% opacity)
- 📋 **xclip** clipboard support
- 🖼️ **xwallpaper** with default Tokyo Night wallpaper
- 🔒 **slock** screen locker

## Project Structure

```
dwm/                       # Clone this repo as 'dwm'
├── install.sh             # Automated installer
├── README.md              # This file
├── dwm-flexipatch/        # Window manager
├── dmenu-flexipatch/      # Application launcher
├── st-flexipatch/         # Terminal emulator
├── slstatus/              # Status bar
├── slock/                 # Screen locker
└── scripts/
    └── autostart.sh       # Startup script
```

## Installation (Minimal Arch Linux)

### Quick Install

```bash
git clone https://github.com/leath86q/wm.git dwm
cd dwm
chmod +x install.sh
./install.sh
```

The install script will:
- Check and install required dependencies
- Build and install dwm, dmenu, st, slstatus, slock
- Configure ~/.xinitrc
- Optionally set up auto-startx on login

### Manual Install

#### 1. Install Prerequisites

```bash
sudo pacman -S --needed \
    base-devel \
    git \
    xorg-server \
    xorg-xinit \
    libx11 \
    libxft \
    libxinerama \
    libxrender \
    ttf-jetbrains-mono-nerd \
    xclip \
    xwallpaper \
    curl
```

| Package | Purpose |
|---------|---------|
| `base-devel` | Compiler and build tools |
| `git` | Clone repositories |
| `xorg-server` | X Window System |
| `xorg-xinit` | `startx` command |
| `libx11` | Core X11 library |
| `libxft` | Font rendering |
| `libxinerama` | Multi-monitor support |
| `libxrender` | X Render extension |
| `ttf-jetbrains-mono-nerd` | Nerd Font with icons |
| `xclip` | Clipboard support |
| `xwallpaper` | Wallpaper setter |
| `curl` | Download wallpaper |

#### 2. Optional: Compositor for Transparency

```bash
sudo pacman -S picom
```

#### 3. Clone Repository

```bash
git clone https://github.com/leath86q/wm.git dwm
cd dwm
```

#### 4. Build & Install

```bash
cd dwm-flexipatch && sudo make clean install
cd ../dmenu-flexipatch && sudo make clean install
cd ../st-flexipatch && sudo make clean install
cd ../slstatus && sudo make clean install
cd ../slock && sudo make clean install
```

#### 5. Setup Autostart

```bash
mkdir -p ~/.local/share/dwm
cp scripts/autostart.sh ~/.local/share/dwm/
chmod +x ~/.local/share/dwm/autostart.sh
```

#### 6. Configure Xinit

Create `~/.xinitrc`:
```bash
exec dwm
```

#### 7. Start X

```bash
startx
```

## Keybindings

**Mod = Super (Windows key)**

### Applications

| Key | Action |
|-----|--------|
| `Mod+Return` | Terminal (st) |
| `Mod+p` | dmenu launcher |
| `Mod+Shift+c` | Close window |
| `Mod+Ctrl+l` | Lock screen |

### Layouts

| Key | Action |
|-----|--------|
| `Mod+t` | Tiled `[T]` |
| `Mod+f` | Floating `[F]` |
| `Mod+m` | Monocle `[M]` |
| `Mod+Space` | Toggle layout |
| `Mod+Shift+Space` | Toggle floating |

### Windows

| Key | Action |
|-----|--------|
| `Mod+j/k` | Focus next/prev |
| `Mod+Shift+j/k` | Move in stack |
| `Mod+Shift+Return` | Promote to master |
| `Mod+h/l` | Resize master |
| `Mod+i/d` | Inc/dec masters |

### Gaps

| Key | Action |
|-----|--------|
| `Mod+Alt+0` | Toggle gaps |
| `Mod+Alt+Shift+0` | Reset gaps |
| `Mod+Alt+u/U` | Inc/dec all gaps |

### Tags

| Key | Action |
|-----|--------|
| `Mod+[1-9]` | View tag |
| `Mod+Shift+[1-9]` | Move to tag |
| `Mod+0` | View all |
| `Mod+Tab` | Previous tag |

### Other

| Key | Action |
|-----|--------|
| `Mod+b` | Toggle bar |
| `Mod+Shift+q` | Quit dwm |

### Mouse

| Action | Result |
|--------|--------|
| `Mod+Left Click` | Move window |
| `Mod+Right Click` | Resize window |
| `Mod+Middle Click` | Toggle floating |

## Configuration Files

| File | Purpose |
|------|---------|
| `dwm-flexipatch/config.h` | Keybindings, rules, appearance |
| `dwm-flexipatch/patches.h` | Enable/disable patches |
| `dmenu-flexipatch/config.h` | Launcher settings |
| `st-flexipatch/config.h` | Terminal settings |
| `slstatus/config.h` | Status bar segments |
| `slock/config.h` | Lock colors |

Rebuild after changes:
```bash
sudo make clean install
```

## Credits

- [dwm-flexipatch](https://github.com/bakkeby/dwm-flexipatch)
- [dmenu-flexipatch](https://github.com/bakkeby/dmenu-flexipatch)
- [st-flexipatch](https://github.com/bakkeby/st-flexipatch)
- [slstatus](https://tools.suckless.org/slstatus/)
- [slock](https://tools.suckless.org/slock/)
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme)
