#!/bin/bash
#
# DWM Stack Installer for Arch Linux
# Installs dwm, dmenu, st, slstatus, slock with Tokyo Night theme
#

# Don't exit on error - we handle errors ourselves
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "Do not run this script as root. It will ask for sudo when needed."
    exit 1
fi

# Check if on Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    print_error "This script is designed for Arch Linux only."
    exit 1
fi

# Get script directory (install.sh is now in the main dwm folder)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Components to build (relative to SCRIPT_DIR)
declare -A COMPONENTS=(
    ["dwm"]="dwm-flexipatch"
    ["dmenu"]="dmenu-flexipatch"
    ["st"]="st-flexipatch"
    ["slstatus"]="slstatus"
    ["slock"]="slock"
)

# Verify all component directories exist
print_status "Verifying component directories..."
MISSING_DIRS=0
for name in "${!COMPONENTS[@]}"; do
    dir="${COMPONENTS[$name]}"
    if [[ ! -d "$SCRIPT_DIR/$dir" ]]; then
        print_error "Component directory not found: $SCRIPT_DIR/$dir"
        MISSING_DIRS=1
    fi
done

if [[ $MISSING_DIRS -eq 1 ]]; then
    print_error "Some component directories are missing. Please check your installation."
    exit 1
fi
print_success "All component directories found"

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          DWM Stack Installer - Tokyo Night Theme          ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo "║  Components: dwm, dmenu, st, slstatus, slock              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# ============================================
# STEP 1: Check and install dependencies
# ============================================
print_status "Checking dependencies..."

PACKAGES=(
    "base-devel"
    "xorg-server"
    "xorg-xinit"
    "xorg-xrandr"
    "libx11"
    "libxft"
    "libxinerama"
    "libxrender"
    "ttf-jetbrains-mono-nerd"
    "xclip"
    "xwallpaper"
    "imagemagick"
    "curl"
)

MISSING_PACKAGES=()

for pkg in "${PACKAGES[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
    print_warning "Missing packages: ${MISSING_PACKAGES[*]}"
    print_status "Installing missing packages..."
    if ! sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"; then
        print_error "Failed to install dependencies"
        exit 1
    fi
    print_success "Dependencies installed"
else
    print_success "All dependencies already installed"
fi

# Optional: Ask about picom
echo ""
read -p "Install picom for transparency effects? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! pacman -Qi picom &>/dev/null; then
        sudo pacman -S --needed --noconfirm picom
        print_success "picom installed"
    else
        print_success "picom already installed"
    fi
fi

# Optional: Ask about LibreWolf (minimal privacy-focused Firefox fork)
echo ""
print_status "LibreWolf is a minimal, privacy-focused Firefox fork (no telemetry, clean UI)"
read -p "Install LibreWolf browser? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! pacman -Qi librewolf &>/dev/null; then
        # LibreWolf is in the AUR, check for yay/paru
        if command -v yay &>/dev/null; then
            yay -S --needed --noconfirm librewolf-bin
            print_success "LibreWolf installed via yay"
        elif command -v paru &>/dev/null; then
            paru -S --needed --noconfirm librewolf-bin
            print_success "LibreWolf installed via paru"
        else
            print_warning "LibreWolf requires an AUR helper (yay or paru)"
            read -p "Install yay first? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installing yay..."
                git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
                (cd /tmp/yay-bin && makepkg -si --noconfirm)
                rm -rf /tmp/yay-bin
                yay -S --needed --noconfirm librewolf-bin
                print_success "LibreWolf installed"
            fi
        fi
    else
        print_success "LibreWolf already installed"
    fi
fi

# ============================================
# STEP 1.5: Generate keybinds wallpaper
# ============================================
echo ""
print_status "Generating keybinds wallpaper..."
WALLPAPER_DIR="$HOME/.local/share/wallpapers"
KEYBINDS_WALLPAPER="$WALLPAPER_DIR/keybinds.png"
FALLBACK_WALLPAPER="$WALLPAPER_DIR/default.jpg"
WALLPAPER_URL="https://w.wallhaven.cc/full/z8/wallhaven-z87z1j.jpg"

mkdir -p "$WALLPAPER_DIR"

# Generate keybinds wallpaper using the script
if [[ -f "$SCRIPT_DIR/scripts/generate-keybinds-wallpaper.sh" ]]; then
    chmod +x "$SCRIPT_DIR/scripts/generate-keybinds-wallpaper.sh"
    if bash "$SCRIPT_DIR/scripts/generate-keybinds-wallpaper.sh" 2>/dev/null; then
        print_success "Keybinds wallpaper generated at $KEYBINDS_WALLPAPER"
    else
        print_warning "Failed to generate keybinds wallpaper (ImageMagick may have issues)"
    fi
else
    print_warning "Keybinds wallpaper script not found"
fi

# Download fallback wallpaper
if [[ ! -f "$FALLBACK_WALLPAPER" ]]; then
    print_status "Downloading fallback wallpaper..."
    if curl -L -o "$FALLBACK_WALLPAPER" "$WALLPAPER_URL" 2>/dev/null; then
        print_success "Fallback wallpaper downloaded to $FALLBACK_WALLPAPER"
    else
        print_warning "Failed to download fallback wallpaper."
    fi
fi

# ============================================
# STEP 2: Build and install components
# ============================================
echo ""
print_status "Building and installing DWM stack..."

build_component() {
    local name=$1
    local dir=$2
    local logfile="/tmp/build_${name}.log"
    
    if [[ ! -d "$dir" ]]; then
        print_error "$name directory not found: $dir"
        return 1
    fi
    
    print_status "Building $name..."
    cd "$dir"
    
    # Clean first (ignore errors)
    make clean > "$logfile" 2>&1 || true
    
    # Build
    if ! make >> "$logfile" 2>&1; then
        print_error "Failed to build $name"
        echo ""
        echo "--- Build log ($logfile) ---"
        tail -30 "$logfile"
        echo "--- End of build log ---"
        echo ""
        return 1
    fi
    
    # Install with sudo (may fail on man pages, so we verify binary instead)
    sudo make install >> "$logfile" 2>&1 || true
    
    # Verify the binary was actually installed
    if [[ -x "/usr/local/bin/$name" ]]; then
        print_success "$name installed successfully"
        rm -f "$logfile"
        return 0
    else
        print_error "Failed to install $name - binary not found"
        echo ""
        echo "--- Build log ($logfile) ---"
        tail -30 "$logfile"
        echo "--- End of build log ---"
        echo ""
        return 1
    fi
}

# Track build results
FAILED_COMPONENTS=()
SUCCESSFUL_COMPONENTS=()

# Build in specific order: dwm, dmenu, st, slstatus, slock
BUILD_ORDER=("dwm" "dmenu" "st" "slstatus" "slock")

for name in "${BUILD_ORDER[@]}"; do
    dir="${COMPONENTS[$name]}"
    if build_component "$name" "$SCRIPT_DIR/$dir"; then
        SUCCESSFUL_COMPONENTS+=("$name")
    else
        FAILED_COMPONENTS+=("$name")
    fi
done

echo ""
# Report results
if [[ ${#SUCCESSFUL_COMPONENTS[@]} -gt 0 ]]; then
    print_success "Successfully installed: ${SUCCESSFUL_COMPONENTS[*]}"
fi

if [[ ${#FAILED_COMPONENTS[@]} -gt 0 ]]; then
    print_error "Failed to install: ${FAILED_COMPONENTS[*]}"
    print_warning "Check the build logs above for details."
    print_warning "You can try building manually: cd <component> && sudo make clean install"
fi

# Verify binaries exist
echo ""
print_status "Verifying installation..."
for cmd in dwm dmenu st slstatus slock; do
    if command -v "$cmd" &>/dev/null; then
        print_success "$cmd installed at $(command -v $cmd)"
    else
        # Check common install location
        if [[ -x "/usr/local/bin/$cmd" ]]; then
            print_success "$cmd installed at /usr/local/bin/$cmd"
        else
            print_warning "$cmd not found in PATH"
        fi
    fi
done

# ============================================
# STEP 3: Setup autostart and utility scripts
# ============================================
echo ""
print_status "Setting up autostart and utility scripts..."

mkdir -p ~/.local/share/dwm
if [[ -f "$SCRIPT_DIR/scripts/autostart.sh" ]]; then
    cp "$SCRIPT_DIR/scripts/autostart.sh" ~/.local/share/dwm/
    chmod +x ~/.local/share/dwm/autostart.sh
    print_success "Autostart script installed to ~/.local/share/dwm/"
else
    print_warning "autostart.sh not found at $SCRIPT_DIR/scripts/autostart.sh"
fi

# Copy wallpaper generator script
if [[ -f "$SCRIPT_DIR/scripts/generate-keybinds-wallpaper.sh" ]]; then
    cp "$SCRIPT_DIR/scripts/generate-keybinds-wallpaper.sh" ~/.local/share/dwm/
    chmod +x ~/.local/share/dwm/generate-keybinds-wallpaper.sh
    print_success "Keybinds wallpaper generator installed"
fi

# ============================================
# STEP 4: Configure .xinitrc with monitor profiles
# ============================================
echo ""
print_status "Configuring .xinitrc..."

XINITRC="$HOME/.xinitrc"

# Copy monitor profile generator script
if [[ -f "$SCRIPT_DIR/scripts/generate-monitor-profiles.sh" ]]; then
    cp "$SCRIPT_DIR/scripts/generate-monitor-profiles.sh" ~/.local/share/dwm/
    chmod +x ~/.local/share/dwm/generate-monitor-profiles.sh
fi

if [[ -f "$XINITRC" ]]; then
    if grep -q "exec dwm" "$XINITRC"; then
        print_success ".xinitrc already configured for dwm"
        # Check if monitor profiles section exists
        if ! grep -q "MONITOR CONFIGURATION" "$XINITRC"; then
            print_warning "Adding monitor profile templates to existing .xinitrc..."
            # Insert monitor profiles before exec dwm
            TEMP_FILE=$(mktemp)
            head -n -2 "$XINITRC" > "$TEMP_FILE"
            cat >> "$TEMP_FILE" << 'MONITOREOF'

# ============================================
# MONITOR CONFIGURATION (xrandr)
# Uncomment ONE profile below or customize for your setup
# Run: ~/.local/share/dwm/generate-monitor-profiles.sh
# to detect your monitors and generate new profiles
# ============================================

# --- Single Monitor Auto (recommended default) ---
# xrandr --output HDMI-1 --auto --primary

# --- Single Monitor 1080p 60Hz ---
# xrandr --output HDMI-1 --mode 1920x1080 --rate 60 --primary

# --- Single Monitor 1080p 144Hz ---
# xrandr --output DP-1 --mode 1920x1080 --rate 144 --primary

# --- Single Monitor 1440p 60Hz ---
# xrandr --output DP-1 --mode 2560x1440 --rate 60 --primary

# --- Single Monitor 1440p 144Hz ---
# xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary

# --- Single Monitor 1440p 165Hz ---
# xrandr --output DP-1 --mode 2560x1440 --rate 165 --primary

# --- Single Monitor 4K 60Hz ---
# xrandr --output DP-1 --mode 3840x2160 --rate 60 --primary

# --- Single Monitor 4K 120Hz ---
# xrandr --output DP-1 --mode 3840x2160 --rate 120 --primary

# --- Dual Monitor (extend right) ---
# xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary \
#        --output HDMI-1 --mode 1920x1080 --rate 60 --right-of DP-1

# --- Dual Monitor (extend left) ---
# xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary \
#        --output HDMI-1 --mode 1920x1080 --rate 60 --left-of DP-1

# --- Dual Monitor (mirror/clone) ---
# xrandr --output DP-1 --mode 1920x1080 --rate 60 --primary \
#        --output HDMI-1 --mode 1920x1080 --rate 60 --same-as DP-1

# --- Triple Monitor ---
# xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary \
#        --output HDMI-1 --mode 1920x1080 --rate 60 --left-of DP-1 \
#        --output DP-2 --mode 1920x1080 --rate 60 --right-of DP-1

# ============================================

MONITOREOF
            tail -2 "$XINITRC" >> "$TEMP_FILE"
            mv "$TEMP_FILE" "$XINITRC"
            chmod +x "$XINITRC"
            print_success "Monitor profiles added to .xinitrc"
        fi
    else
        print_warning ".xinitrc exists but doesn't start dwm"
        read -p "Append 'exec dwm' to .xinitrc? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "" >> "$XINITRC"
            echo "# Start dwm" >> "$XINITRC"
            echo "exec dwm" >> "$XINITRC"
            print_success ".xinitrc updated"
        fi
    fi
else
    cat > "$XINITRC" << 'EOF'
#!/bin/sh

# Source system xinitrc scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# ============================================
# MONITOR CONFIGURATION (xrandr)
# Uncomment ONE profile below or customize for your setup
# Run: ~/.local/share/dwm/generate-monitor-profiles.sh
# to detect your monitors and generate new profiles
# ============================================

# --- Single Monitor Auto (recommended default) ---
# xrandr --output HDMI-1 --auto --primary

# --- Single Monitor 1080p 60Hz ---
# xrandr --output HDMI-1 --mode 1920x1080 --rate 60 --primary

# --- Single Monitor 1080p 144Hz ---
# xrandr --output DP-1 --mode 1920x1080 --rate 144 --primary

# --- Single Monitor 1440p 60Hz ---
# xrandr --output DP-1 --mode 2560x1440 --rate 60 --primary

# --- Single Monitor 1440p 144Hz ---
# xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary

# --- Single Monitor 1440p 165Hz ---
# xrandr --output DP-1 --mode 2560x1440 --rate 165 --primary

# --- Single Monitor 4K 60Hz ---
# xrandr --output DP-1 --mode 3840x2160 --rate 60 --primary

# --- Single Monitor 4K 120Hz ---
# xrandr --output DP-1 --mode 3840x2160 --rate 120 --primary

# --- Dual Monitor (extend right) ---
# xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary \
#        --output HDMI-1 --mode 1920x1080 --rate 60 --right-of DP-1

# --- Dual Monitor (extend left) ---
# xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary \
#        --output HDMI-1 --mode 1920x1080 --rate 60 --left-of DP-1

# --- Dual Monitor (mirror/clone) ---
# xrandr --output DP-1 --mode 1920x1080 --rate 60 --primary \
#        --output HDMI-1 --mode 1920x1080 --rate 60 --same-as DP-1

# --- Triple Monitor ---
# xrandr --output DP-1 --mode 2560x1440 --rate 144 --primary \
#        --output HDMI-1 --mode 1920x1080 --rate 60 --left-of DP-1 \
#        --output DP-2 --mode 1920x1080 --rate 60 --right-of DP-1

# ============================================

# Start dwm
exec dwm
EOF
    chmod +x "$XINITRC"
    print_success ".xinitrc created with monitor profiles"
fi

# ============================================
# STEP 5: Optional auto-startx on login
# ============================================
echo ""
read -p "Auto-start X on TTY1 login? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    PROFILE="$HOME/.bash_profile"
    STARTX_LINE='[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx'
    
    if [[ -f "$PROFILE" ]] && grep -qF "$STARTX_LINE" "$PROFILE"; then
        print_success "Auto-startx already configured"
    else
        echo "" >> "$PROFILE"
        echo "# Auto-start X on TTY1" >> "$PROFILE"
        echo "$STARTX_LINE" >> "$PROFILE"
        print_success "Auto-startx configured in .bash_profile"
    fi
fi

# ============================================
# Done!
# ============================================
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete!                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "To start dwm:"
echo "  1. Log out of any desktop environment"
echo "  2. Switch to a TTY (Ctrl+Alt+F2)"
echo "  3. Log in and run: startx"
echo ""
echo "Key bindings (see wallpaper for full list):"
echo "  Mod+Return     Open terminal"
echo "  Mod+p          Open dmenu"
echo "  Mod+Shift+c    Close window"
echo "  Mod+Shift+q    Quit dwm"
echo ""
echo "Monitor configuration:"
echo "  Edit ~/.xinitrc and uncomment your monitor profile"
echo "  Run: ~/.local/share/dwm/generate-monitor-profiles.sh"
echo "  to detect monitors and generate custom profiles"
echo ""
echo "Wallpapers:"
echo "  Keybinds: ~/.local/share/wallpapers/keybinds.png"
echo "  Regenerate: ~/.local/share/dwm/generate-keybinds-wallpaper.sh"
echo ""
print_success "Enjoy your new desktop!"
