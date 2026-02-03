# Copilot Instructions for wm

## Project Overview

Suckless window manager setup with **Tokyo Night** theme for **Arch Linux**. This is a **flexipatch-based** configuration where patches are compile-time toggles rather than literal patch files.

## Architecture

The project consists of 5 suckless components, each using the flexipatch approach:

```
dwm/                       # Root (this repo clones as 'dwm')
├── install.sh             # Automated installer for all components
├── dwm-flexipatch/        # Window manager (core)
├── dmenu-flexipatch/      # Application launcher
├── st-flexipatch/         # Terminal emulator
├── slstatus/              # Status bar (not flexipatch)
├── slock/                 # Screen locker (not flexipatch)
└── scripts/autostart.sh   # Runs at dwm startup
```

### Component Responsibilities
- **dwm-flexipatch**: Window management, keybindings, bar rendering, layout logic
- **dmenu-flexipatch**: Fuzzy-search application launcher (Mod+p)
- **st-flexipatch**: Terminal emulator with Tokyo Night colors and transparency
- **slstatus**: Status bar text generator (CPU/RAM/disk/time)
- **slock**: Screen locker triggered via Mod+Ctrl+l

## Critical Build System Knowledge

### Flexipatch Pattern
**Never manually apply `.patch` files.** Instead:
1. Edit `patches.h` to toggle features: `#define FEATURE_PATCH 1` (enable) or `0` (disable)
2. Copy `config.def.h` → `config.h` **only on first install**
3. Modify `config.h` for theming/keybinds (never edit `config.def.h`)
4. Ensure `config.mk` has required libs enabled (e.g., `-lXrender` for alpha)

### Build Commands
```bash
# From any component directory (dwm-flexipatch, dmenu-flexipatch, st-flexipatch, etc.)
sudo make clean install

# Full stack rebuild (from dwm/ root)
for dir in dwm-flexipatch dmenu-flexipatch st-flexipatch slstatus slock; do
    (cd "$dir" && sudo make clean install)
done
```

### Config File Precedence
- `config.mk`: Build flags, library linking (`XRENDER`, `XINERAMA`, etc.)
- `patches.h`: Feature toggles (must be set BEFORE compile)
- `config.h`: Runtime config (colors, keybinds, rules) - this is what you edit

**Critical**: `config.h` is **not tracked** in git if generated from `config.def.h`. The tracked version in this repo is the customized one.

## Active Patches (Essential to Know)

### dwm-flexipatch
- `BAR_ALPHA_PATCH=1` - Transparent bar (requires `-lXrender` in config.mk)
- `VANITYGAPS_PATCH=1` - 10px gaps on all sides (toggleable with Mod+Alt+0)
- `ALWAYSCENTER_PATCH=1` - Floating windows auto-center (cannot be disabled without recompile)
- `ATTACHBOTTOM_PATCH=1` - New clients spawn at bottom of stack, not top
- `AUTOSTART_PATCH=1` - Runs `~/.local/share/dwm/autostart.sh` on startup
- `PERTAG_PATCH=1` - Each tag remembers its own layout (tiled/float/monocle)

### dmenu-flexipatch
- `FUZZYMATCH_PATCH=1` + `CASEINSENSITIVE_PATCH=1` - Type any substring to filter
- `CENTER_PATCH=1` - Appears in screen center (500px min width)
- `HIGHPRIORITY_PATCH=1` - Priority apps shown first (configured in dwm's dmenucmd)
- `HIGHLIGHT_PATCH=1` - Matched characters highlighted in orange
- `LINE_HEIGHT_PATCH=1` - 32px line height for vertical list
- `lines=15` - Shows as vertical list menu, not horizontal bar

### st-flexipatch
- `ALPHA_PATCH=1` - 95% opacity (config: `unsigned int alpha = 0xf2;`)
- `ANYSIZE_PATCH=1` - Eliminates padding when resizing
- `CLIPBOARD_PATCH=1` - Ctrl+Shift+C/V for system clipboard
- `SCROLLBACK_PATCH=1` + `SCROLLBACK_MOUSE_PATCH=1` - Scroll history with Shift+PageUp/PageDown or mouse

## Tokyo Night Color Scheme (Hardcoded)

All `config.h` files reference these exact hex values:
- `#1a1b26` - Background (dark blue-gray)
- `#c0caf5` - Foreground (light blue-white)
- `#7aa2f7` - Primary accent (blue) - used for selections, focused borders
- `#bb9af7` - Purple (secondary accent)
- `#9ece6a` - Green (success states)

**Never use approximate colors** - these are Tokyo Night canonical. Check slstatus/config.h for `^c#7aa2f7^` status color codes.

## Developer Workflows

### Adding a New Patch
1. Find patch in `patches.def.h` (the reference file)
2. Set `#define NEW_PATCH 1` in `patches.h`
3. Check if `config.mk` needs new libs (comments indicate dependencies)
4. Add required config vars to `config.h` (refer to comments in `config.def.h`)
5. `sudo make clean install`

### Changing Keybindings
Edit `dwm-flexipatch/config.h`:
```c
static Key keys[] = {
    { MODKEY, XK_Return, spawn, CMD("st") },  // Mod+Return = terminal
    { MODKEY, XK_p, spawn, CMD("dmenu_run") }, // Mod+p = launcher
};
```
- `MODKEY` = Super/Windows key (defined as `Mod4Mask`)
- Use helper macros: `CMD(...)` for simple commands, `SHCMD("...")` for shell commands

### Modifying Bar Appearance
- **Layout symbol**: `dwm-flexipatch/config.h` → `static const Layout layouts[]` (e.g., `"[T]"`, `"[F]"`, `"[M]"`)
- **Status text**: `slstatus/config.h` → Uses `^c#RRGGBB^` for colors, `^d^` to reset
- **Bar opacity**: `dwm-flexipatch/config.h` → `unsigned int baralpha = 0xf2;` (0x00=transparent, 0xff=opaque)

### Testing Without Installing
```bash
# Run locally without sudo make install
cd dwm-flexipatch
make
./dwm  # This will fail if X is already running - use Xephyr for testing
```

## Installation Script Behavior

`install.sh` is idempotent and checks:
1. Arch Linux (`/etc/arch-release`)
2. Not running as root (uses sudo internally)
3. All component directories exist (dwm-flexipatch, dmenu-flexipatch, etc.)
4. Installs missing pacman packages non-interactively
5. Offers to configure `~/.xinitrc` and auto-startx on login

**Skip interactive prompts**: Run with `yes | ./install.sh` for CI/automation.

## Common Pitfalls

1. **Bar not transparent**: Forgot `-lXrender` in `config.mk` or `BAR_ALPHA_PATCH=0`
2. **Gaps not working**: `VANITYGAPS_PATCH=0` or terminal has internal padding (check st config)
3. **dmenu not fuzzy**: `FUZZYMATCH_PATCH=0` - verify in `dmenu-flexipatch/patches.h`
4. **Clipboard broken in st**: Missing `xclip` package or `CLIPBOARD_PATCH=0`
5. **slstatus not showing**: Check if `~/.local/share/dwm/autostart.sh` is executable and called by `AUTOSTART_PATCH`

## Quick Reference: Key Files by Task

| Task | File |
|------|------|
| Add/remove DWM features | `dwm-flexipatch/patches.h` |
| Change keybindings | `dwm-flexipatch/config.h` (look for `static Key keys[]`) |
| Modify status bar text | `slstatus/config.h` (look for `static const struct arg args[]`) |
| Change terminal colors | `st-flexipatch/config.h` (look for `static const char *colorname[]`) |
| Adjust transparency | `dwm-flexipatch/config.h` (`baralpha`) or `st-flexipatch/config.h` (`alpha`) |
| Screen locker colors | `slock/config.h` (look for `static const char *colorname[]`) |
| Startup applications | `scripts/autostart.sh` (copied to `~/.local/share/dwm/`) |
