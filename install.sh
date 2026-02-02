#!/bin/bash
#
# DWM Stack Installer for Arch Linux
# Installs dwm, dmenu, st, slstatus, slock with Tokyo Night theme
#

set -e

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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DWM_DIR="$SCRIPT_DIR/dwm"

if [[ ! -d "$DWM_DIR" ]]; then
    print_error "dwm directory not found at $DWM_DIR"
    exit 1
fi

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
    "libx11"
    "libxft"
    "libxinerama"
    "libxrender"
    "ttf-jetbrains-mono-nerd"
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
    sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"
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

# ============================================
# STEP 2: Build and install components
# ============================================
echo ""
print_status "Building and installing DWM stack..."

build_component() {
    local name=$1
    local dir=$2
    
    if [[ -d "$dir" ]]; then
        print_status "Building $name..."
        cd "$dir"
        sudo make clean install >/dev/null 2>&1
        print_success "$name installed"
    else
        print_error "$name directory not found: $dir"
        return 1
    fi
}

build_component "dwm" "$DWM_DIR/dwm-flexipatch"
build_component "dmenu" "$DWM_DIR/dmenu-flexipatch"
build_component "st" "$DWM_DIR/st-flexipatch"
build_component "slstatus" "$DWM_DIR/slstatus"
build_component "slock" "$DWM_DIR/slock"

# ============================================
# STEP 3: Setup autostart script
# ============================================
echo ""
print_status "Setting up autostart..."

mkdir -p ~/.local/share/dwm
cp "$DWM_DIR/scripts/autostart.sh" ~/.local/share/dwm/
chmod +x ~/.local/share/dwm/autostart.sh
print_success "Autostart script installed to ~/.local/share/dwm/"

# ============================================
# STEP 4: Configure .xinitrc
# ============================================
echo ""
print_status "Configuring .xinitrc..."

XINITRC="$HOME/.xinitrc"

if [[ -f "$XINITRC" ]]; then
    if grep -q "exec dwm" "$XINITRC"; then
        print_success ".xinitrc already configured for dwm"
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

# Start dwm
exec dwm
EOF
    chmod +x "$XINITRC"
    print_success ".xinitrc created"
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
echo "Key bindings:"
echo "  Mod+Return     Open terminal"
echo "  Mod+p          Open dmenu"
echo "  Mod+Shift+c    Close window"
echo "  Mod+Shift+q    Quit dwm"
echo ""
print_success "Enjoy your new desktop!"
