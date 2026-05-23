# Linux-specific dotfile TODOs

Long-form list of Linux-only exploration tasks that don't yet warrant inlining in `.claude/CLAUDE.md`. The CLAUDE.md "Open dotfile-related TODOs → Linux" section is the index; this file is the prose.

When to consult this file:
- Bootstrapping a fresh Linux box and deciding which DE / WM / tooling to use.
- Considering platform-specific tooling that has no Mac equivalent or differs meaningfully.
- Tracking experiments the user is curious about but hasn't committed to yet.

Items here are speculative; do not implement without asking. None of these are committed direction — they're explore-and-decide entries.

## Evaluate moving to Wayland from X11

- **Status:** Not started. Current box (Ubuntu 24.04, NVIDIA 595) is on GNOME + X11 (`XDG_SESSION_TYPE=x11`).
- **Why:** Wayland is the long-term default for GNOME / KDE / most modern DEs; X11 sessions are gradually deprecated. NVIDIA driver support has improved a lot in 2025+. Moving proactively avoids being forced into it later mid-workflow.
- **Why not yet:** X11-specific tooling in this repo (`.config/awesome` for awesome WM, `.config/regolith/i3/config` for i3, `xclip` for clipboard) needs Wayland equivalents (sway/hyprland/niri, `wl-copy`). Some apps (espanso, screen recording, the dygma config tool) may behave differently.
- **How to approach:** Log into the "Ubuntu on Wayland" session at GDM, evaluate which dotfile-managed apps still work cleanly, what breaks, what needs reconfiguring. Don't commit yet — reboot back into X11 if anything important is missing. If/when committing: replace `xclip` with `wl-clipboard` in `home.nix`, decide on a tiling WM (see below).

## Pick a Wayland-native tiling window manager

- **Status:** Not started. Tied to the Wayland-move decision above.
- **Why:** X11 tiling WMs (i3, awesome) don't work under Wayland. Modern options:
  - **Sway** — drop-in i3 replacement, same config language. Lowest friction if migrating from i3.
  - **Hyprland** — animation-rich, modern, very active. Visual polish.
  - **Niri** — scrollable tiling (no traditional workspaces). Fresh paradigm; consider only if curious about a different model.
  - **river** — lightweight, dynamic. Less mature but minimalist.
- **How to approach:** Pick based on philosophy (Sway if "stay close to i3 muscle memory," Hyprland for polish, Niri for a different paradigm). Add as a home-manager package + config file. GDM doesn't auto-detect arbitrary Wayland WMs — may need a `.desktop` session file in `/usr/share/wayland-sessions/` or switch DM (e.g., `tuigreet`, `ly`).

## Status bar + desktop niceties for a tiling WM setup

- **Status:** Not started. Only relevant after committing to a tiling WM.
- **Why:** Tiling WMs don't ship a status bar; GNOME Shell's top bar disappears when you leave GNOME. Need replacements for: status info, notifications, lock screen, app launcher.
- **Candidate stack (assumes Sway or Hyprland):**
  - Status bar: **waybar** (most popular, JSON-config) or **eww** (highly customizable, declarative)
  - Notifications: **mako** or **fnott**
  - Lock screen: **swaylock** / **hyprlock**
  - Launcher: **wofi** (rofi-like) / **fuzzel** / **anyrun**
  - Wallpaper: **swaybg** / **hyprpaper**
- **How to approach:** Decide the full stack at once — they integrate (e.g., waybar shows mako's notification count). Don't piecemeal.
