# Linux-specific dotfile TODOs

Long-form list of Linux-only exploration tasks that don't yet warrant inlining in `.claude/CLAUDE.md`. The CLAUDE.md "Open dotfile-related TODOs → Linux" section is the index; this file is the prose.

When to consult this file:
- Bootstrapping a fresh Linux box and deciding which DE / WM / tooling to use.
- Considering platform-specific tooling that has no Mac equivalent or differs meaningfully.
- Tracking experiments the user is curious about but hasn't committed to yet.

Items here are speculative; do not implement without asking. None of these are committed direction — they're explore-and-decide entries.

## Evaluate moving to Wayland from X11

- **Status:** Deferred until later, watching MuJoCo [#2393](https://github.com/google-deepmind/mujoco/issues/2393), and evaluating Tiling WM options. Current box (Ubuntu 24.04, NVIDIA 595) is on GNOME + X11 (`XDG_SESSION_TYPE=x11`); session-switch is free at GDM (both `ubuntu.desktop` and `ubuntu-wayland.desktop` are installed).
- **Why deferred (2026-05-23):** MuJoCo's GUI viewer has active Wayland breakage — `mjr_makeContext` returns `GL_INVALID_OPERATION` and `mjr_render` errors with "required buffer is missing" on Wayland sessions, and the bug is in MuJoCo's own rendering code, not just GLFW (so XWayland doesn't fully save you either). Workable escape hatch is launching with `WAYLAND_DISPLAY= XDG_SESSION_TYPE=x11 python -m mujoco.viewer`, but that's per-invocation friction. MuJoCo is on the near-term tool list, so X11 stays the lower-friction default for now. URSim is *not* a constraint — it ships as a Docker image (UR's recommended path) or VM, both of which sidestep the host display server entirely.
- **Why Wayland is still on the table:** Long-term default for GNOME / KDE / most modern DEs; X11 sessions are gradually deprecated. NVIDIA driver support is solid post-555 (we're on 595). Wayland-native tiling WMs (Sway, Hyprland, Niri) are also Wayland-only, so any future tiling-WM exploration drags this decision along.
- **What's X11-coupled in this repo (audit done 2026-05-23):** `home.nix:32` has `xclip` package, used in `config.fish:14` by the `2fa` function (`oathtool ... | xclip -sel clip`). The `awesome/`, `i3.config`, `Xresources-regolith` dirs are X11-only but already inert under GNOME. Nvim's `set clipboard+=unnamedplus` auto-detects between `wl-copy` / `xclip` / `xsel` providers, so no change needed there.
- **How to re-evaluate when picking this up:**
  1. Confirm MuJoCo #2393 has shipped a fix (or the user has moved off MuJoCo).
  2. Pre-flight: add `wl-clipboard` to `home.nix` alongside `xclip`; rewrite `2fa` in `config.fish` to detect session type (`if test -n "$WAYLAND_DISPLAY"; wl-copy; else; xclip -sel clip; end`). Both changes are safe under X11 too.
  3. Log out → "Ubuntu on Wayland" at GDM → smoke-test kitty / tmux / nvim clipboard / GNOME extensions / screen recording / Electron apps (Logseq, Bazecor).
  4. If clean: commit pre-flight changes; the `awesome/`, `i3.config`, `Xresources-regolith` files can stay (harmless legacy) or be deleted at the same time as adopting a Wayland-native tiling WM.
  5. If broken: log back into X11 at GDM; the pre-flight changes remain a no-op until next attempt.

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
