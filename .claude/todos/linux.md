# Linux-specific dotfile TODOs

Long-form list of Linux-only exploration tasks that don't yet warrant inlining in `.claude/CLAUDE.md`. The CLAUDE.md "Open dotfile-related TODOs → Linux" section is the index; this file is the prose.

When to consult this file:
- Bootstrapping a fresh Linux box and deciding which DE / WM / tooling to use.
- Considering platform-specific tooling that has no Mac equivalent or differs meaningfully.
- Tracking experiments the user is curious about but hasn't committed to yet.

Items here are speculative; do not implement without asking. None of these are committed direction — they're explore-and-decide entries.

## Wayland migration (in progress)

- **Status:** GNOME-Wayland is the active session as of 2026-05-24. Sway-from-scratch is the agreed end state — see the tiling-WM section below. The MuJoCo blocker is acknowledged and we accept the per-invocation env-var workaround instead of waiting on [#2393](https://github.com/google-deepmind/mujoco/issues/2393).
- **What's done:** `wl-clipboard` added to `home.nix` alongside `xclip` (both coexist; nvim auto-detects). `config.fish` `2fa` function detects `$WAYLAND_DISPLAY` and routes to `wl-copy` or `xclip -sel clip`. Existing legacy X11 dirs (`awesome/`, `i3.config`, `Xresources-regolith`) stay inert for now — retirement is bundled with the Sway adoption work.
- **MuJoCo workaround:** Launch with `WAYLAND_DISPLAY= XDG_SESSION_TYPE=x11 python -m mujoco.viewer` (or shell-alias it). Issue [#2393](https://github.com/google-deepmind/mujoco/issues/2393) is the canary for when we can drop the alias.
- **What's still ahead:** Sway build-out (next major chunk) — see below.

## Adopt Sway tiling WM (from-scratch config)

- **Status:** Decided 2026-05-24. Sway, configured by us, no Regolith. Reasoning: avoid being beholden to Regolith's release cycle / Xresource-key renames / forked `regolith-control-center`; commit to a one-time setup that then sits still for years.
- **Stance:** No time-to-value pressure. GNOME-Wayland stays the daily driver until the Sway setup is actually polished. We build it in evenings and switch sessions when it's good.
- **Why not Hyprland:** higher maintenance ceiling, more config knobs, more active-dev breakage. Aesthetic ceiling is higher but doesn't justify the ongoing tweaking for our value weighting (low maintenance ≥ maturity ≥ aesthetics ≥ low migration churn).
- **Why not Regolith:** evaluated 2026-05-24. Less invasive than feared (doesn't replace GDM, doesn't touch Nix/Docker/Python), but: uninstall is dirty ([issue 474](https://github.com/regolith-linux/regolith-desktop/issues/474), closed without fix); `do-release-upgrade` silently strips their APT repo; binary-path confusion if home-manager also installs rofi/dunst; we'd inherit their release cycle (e.g. past Xresource prefix rename in 3.0). Pre-packaged convenience didn't outweigh the cycle dependency.
- **Components — only the WM is settled; everything else is a category with 2–4 realistic Wayland candidates to pick collaboratively:**
  - WM: **Sway** (settled)
  - Status bar: Waybar / eww / Ironbar
  - App launcher: Rofi 2.x / Fuzzel / Tofi (wofi excluded — unmaintained per its own author)
  - Notifications: Mako / Dunst / fnott
  - Lock + idle: swaylock-effects+swayidle / hyprlock+hypridle / gtklock+swayidle
  - Wallpaper: swaybg / swww / hyprpaper
  - Screenshot: grim+slurp+satty / grim+slurp+swappy / hyprshot
  - Volume tool + OSD: pamixer/pactl/wpctl + wob/avizo/SwayOSD
  - Brightness: brightnessctl / light
  - Compositor: built into Sway (no separate tool)
  - Theme palette: Catppuccin / Gruvbox / Nord / Tokyonight / Rose Pine / custom
  - Font: depends on the Mono Lisa Linux TODO (or pick a stand-in)
- **Decision process** (when picking this up): for each category, weigh against the value ordering (low maintenance ≥ maturity ≥ aesthetics ≥ low migration churn), Claude pitches a recommendation, user signs off, install + configure + verify before moving to the next category. Track session-level decisions in the task list (`#30`–`#38`).
- **Order of work**: WM (install Sway, write fresh config porting Colemak-DH bindings from old `i3.config:112-116, 171-175`) → bar (#30) → launcher (#31) → notifications (#32) → lock+idle (#33) → screenshot (#34) → wallpaper (#35) → media keys (#36) → theme + fonts (#37) → tray-app validation (#38) → log out → pick Sway at GDM → iterate.
- **Where we left off (2026-05-24):** Candidate sets per category are above and mirrored in tasks `#30`–`#38`. Nothing Sway-related has been installed yet. The user is still on GNOME-Wayland; the existing daily-driver stays put until the Sway setup is polished. Pre-flight pieces (wl-clipboard, 2fa fish function) already landed.
- **Resumption prompt — Claude should open the next session with this question, verbatim:**
  > Pick the order — start with the WM install + config, or do the component picks first on paper before any installs?

  Either path works. Installing the WM first gets a Sway session standing up at GDM, so subsequent component picks can be validated live. Doing paper picks first reduces churn (no half-configured installs) but means you don't see each component in its actual home until the end.
