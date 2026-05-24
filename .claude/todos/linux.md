# Linux-specific dotfile TODOs

Canonical list of Linux-only TODOs. See sibling files for other scopes:

- `todos.md` — generic / cross-platform dotfile TODOs
- `mac.md` — macOS-specific

Memory's `~/.claude/projects/-Users-zyst/memory/todos.md` mirrors items per the sync rule in CLAUDE.md, but **this file is the canonical, in-repo source** — it survives an OS hop, while memory is per-machine.

Mix of long-form exploration items (Wayland switch, Sway from-scratch — decision-pending) and concrete tasks (Logseq Sync, Tailscale, etc. — actionable). When picking an item, walk it didactically (one change at a time, adopt/decline, test, commit). Done items get deleted from this file outright — see `feedback_todo_deletion.md` memory entry for the rule. Speculative items below are tagged as such; don't implement without asking.

---

## Wayland migration (in progress)

- **Status:** GNOME-Wayland is the active session as of 2026-05-24. Sway-from-scratch is the agreed end state — see the tiling-WM section below. The MuJoCo blocker is acknowledged and we accept the per-invocation env-var workaround instead of waiting on [#2393](https://github.com/google-deepmind/mujoco/issues/2393).
- **What's done:** `wl-clipboard` added to `home.nix` alongside `xclip` (both coexist; nvim auto-detects). `config.fish` `2fa` function detects `$WAYLAND_DISPLAY` and routes to `wl-copy` or `xclip -sel clip`. Existing legacy X11 dirs (`awesome/`, `i3.config`, `Xresources-regolith`) stay inert for now — retirement is bundled with the Sway adoption work.
- **MuJoCo workaround:** Launch with `WAYLAND_DISPLAY= XDG_SESSION_TYPE=x11 python -m mujoco.viewer` (or shell-alias it). Issue [#2393](https://github.com/google-deepmind/mujoco/issues/2393) is the canary for when we can drop the alias.
- **What's still ahead:** Sway build-out (next major chunk) — see below.

---

## Adopt Sway tiling WM (from-scratch config) [speculative — decision-pending sub-components]

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
- **Source-of-truth for the new Sway config (decided 2026-05-24):** the local `i3.config` is **semi-abandoned**. When porting bindings, Regolith's upstream Sway/i3 configs are the canonical reference — they reflect current best practice for the Regolith-style workflow we lived in. Use the local `i3.config` only for the **Colemak-DH directional adjustments** (lines `112-116, 171-175`); Regolith ships QWERTY defaults. Same principle applies if any other narrow local override exists — port the override, not the whole file.
- **Order of work**: WM (install Sway; write fresh config seeded from Regolith upstream + Colemak-DH override) → bar (#30) → launcher (#31) → notifications (#32) → lock+idle (#33) → screenshot (#34) → wallpaper (#35) → media keys (#36) → theme + fonts (#37) → tray-app validation (#38) → log out → pick Sway at GDM → iterate.
- **Where we left off (2026-05-24):** Candidate sets per category are above and mirrored in tasks `#30`–`#38`. Nothing Sway-related has been installed yet. The user is still on GNOME-Wayland; the existing daily-driver stays put until the Sway setup is polished. Pre-flight pieces (wl-clipboard, 2fa fish function) already landed.
- **Resumption prompt — Claude should open the next session with this question, verbatim:**
  > Pick the order — start with the WM install + config, or do the component picks first on paper before any installs?

  Either path works. Installing the WM first gets a Sway session standing up at GDM, so subsequent component picks can be validated live. Doing paper picks first reduces churn (no half-configured installs) but means you don't see each component in its actual home until the end.

---

## Set up Logseq Sync on Linux and verify round-trip with Mac / iOS

- **Status:** Not started. Logseq Sync verified working Mac ↔ iOS as of 2026-05-23; Linux is the remaining device.
- **Why:** Dotfiles repo ships to Linux (and WSL) — user wants the Logseq graph available on the Linux machine too with the same Sync setup so all devices stay consistent. This TODO lives in the dotfiles repo (rather than purely in global memory) because the Linux side has a real dotfiles component: Logseq is not currently in `home.nix`, so the first step is a home-manager package addition.
- **How to apply:**
  1. Verify the Logseq attribute on the locally-pinned nixpkgs (likely `pkgs.logseq` — confirm via `nix-instantiate --eval -E '(import <nixpkgs> {}).logseq.meta.position'` or by searching the pinned channel). Add it to `home.nix` (the Linux entrypoint / shared base — keep out of `home-mac.nix` if Mac's existing non-Nix install should stay authoritative there). If Logseq isn't packaged for Linux in nixpkgs, fall back to AppImage / Flatpak and document the chosen mechanism here. Avoid imperative installs that don't survive a fresh-machine rebuild.
  2. `home-manager switch`.
  3. Launch Logseq on Linux, sign in with the same account used on Mac / iOS, enable Sync, pull the synced graph.
  4. Round-trip a test edit Linux → Mac (or iOS) and back to confirm both directions before treating this as done.
  5. While on this, opportunistically test the **plugin-sync open question** from the global `todos.md` "Bring Logseq plugin set..." entry: does the `Cologler/logseq-remove-empty-blocks-typescript` plugin (once installed on Mac) auto-appear on Linux after Sync? Answering it here unblocks the plugin-sync TODO.

---

## Verify `noti` fires notifications on Linux

- **Status:** `noti` is installed via `home.nix` (cross-platform package, lands on Linux via the same Nix expression). Mac side verified working 2026-05-24. Linux side untested.
- **Why:** `noti` uses libnotify's `notify-send` mechanism on Linux, which requires a notification daemon running on the bus. On GNOME-Wayland (the current Linux session) that daemon should be GNOME Shell's built-in one. After the Sway migration, the daemon is part of the Sway plan candidate set (mako / dunst / fnott — see the Sway section above).
- **How to apply:** Next time on Linux, run `noti -t Test -m hi` from a fresh fish prompt. If it pops a notification, done — record here and move on. If not, debug: confirm a notification daemon is active (`busctl --user list | grep Notif`), confirm libnotify CLI works (`notify-send Test hi`), then diagnose noti's libnotify backend.

---

## Set up Tailscale on Linux and verify Mac → Linux SSH

- **Status:** Not started. Surfaced 2026-05-24.
- **Why:** User wants Mac-from-anywhere SSH access to the Linux box without exposing it to the public internet, port-forwarding on the router, or maintaining dynamic DNS. Tailscale gives both machines a stable name on the user's tailnet with WireGuard-backed connectivity, and (optionally) replaces `~/.ssh/authorized_keys` management with tailnet ACLs via Tailscale SSH. This unblocks workflows like editing on Mac while running long jobs on Linux, and is a prerequisite for "rebuild a machine and rejoin the fleet" being a real story.
- **How to apply:**
  1. **Linux daemon install.** Tailscale needs a root daemon (`tailscaled`), which is *not* a home-manager option. Two paths depending on the distro:
     - **Non-NixOS Linux (current Ubuntu-flavored box):** install via the upstream apt repo (`curl -fsSL https://tailscale.com/install.sh | sh`) and `sudo systemctl enable --now tailscaled`. This is imperative and won't survive a rebuild-from-dotfiles-alone — note this caveat here when done.
     - **NixOS (if the box is ever migrated):** add `services.tailscale.enable = true;` in `/etc/nixos/configuration.nix`, then `nixos-rebuild switch`. Fully declarative.
  2. `sudo tailscale up` on Linux, authenticate via browser, note the resulting tailnet hostname (e.g. `linux-box.tailXXXX.ts.net` or whatever short name is assigned). Record the hostname here once known.
  3. **Mac side:** verify Tailscale is installed and authenticated to the same tailnet. If not, install — the Mac App Store binary is the most featureful (system extension for the magic-DNS resolver); `brew install --cask tailscale` is the equivalent path; `pkgs.tailscale` (home-manager) gives the CLI only. Decide which Mac path to commit to and capture the decision here.
  4. **SSH baseline (Linux):** confirm `sshd` is running (`systemctl status sshd` or `systemctl status ssh` depending on the distro — Ubuntu uses `ssh.service`). If absent, `sudo apt install openssh-server` and enable the service. Check the firewall (`ufw status` if active) isn't blocking 22 over the tailnet interface — Tailscale by default accepts inbound on its own interface, but a strict `ufw default deny` plus no explicit allow may interfere.
  5. **Authentication — pick one of two paths:**
     - **Traditional `authorized_keys`:** copy the Mac's SSH public key to Linux (`ssh-copy-id zyst@<linux-tailnet-hostname>` once Tailscale connectivity is up, or paste `~/.ssh/id_ed25519.pub` directly into Linux's `~/.ssh/authorized_keys`).
     - **Tailscale SSH** (`tailscale up --ssh` on Linux): replaces `authorized_keys` entirely. Auth is gated by tailnet ACLs in the Tailscale admin console. Lower maintenance, but means losing access to the Linux box if the tailnet is unreachable for any reason (auth-server-side outage, expired auth keys, etc.). For a single-user setup either is fine; document the choice.
  6. **Verify:** from Mac, `ssh zyst@<linux-tailnet-hostname>` should land in a Linux shell. Then test resilience:
     - Reboot Linux → confirm `tailscaled` rejoins the tailnet automatically and SSH still resolves.
     - Close Mac lid, reopen → confirm SSH still resolves (Tailscale should reconnect transparently).
     - Move Mac to a different network → confirm tailnet hostname still resolves and SSH still works.
  7. **Decide on `tailscale up` flags worth keeping:**
     - `--ssh` — enable Tailscale SSH (see auth choice above).
     - `--operator=$USER` — lets the non-root user run `tailscale` CLI commands (status, ping, etc.) without sudo. Strongly recommended.
     - `--accept-routes` — only matters if you ever run subnet routers on the tailnet; safe to omit until that's a thing.
     - `--exit-node=<host>` — only for routing all traffic through another tailnet node; not relevant for SSH-only access.
  8. **Document the final setup here once done:** install path used on each side, Tailscale-SSH vs `authorized_keys` outcome, resulting tailnet hostnames. This makes the "rebuild a fresh Linux box" story repeatable without re-deriving every decision.
- **Open question worth resolving up front:** is the goal *only* Mac → Linux, or also bidirectional (Linux → Mac, plus eventually iOS / WSL on the same tailnet)? Tailscale handles all directions transparently once each device is on the tailnet, but the auth model (Tailscale SSH ACLs vs. per-device `authorized_keys`) is easier to design once than retrofit.
- **Adjacent:** once the path is settled, consider adding `pkgs.tailscale` to `home.nix` (and `home-mac.nix` if the Mac side ends up using the CLI rather than the GUI binary) so the dotfiles repo at least captures the CLI dependency, even though the daemon itself stays system-level. If the `common.nix` refactor (`todos.md`) lands first, add Tailscale there only if both platforms end up using the home-manager CLI; otherwise keep it in the relevant platform file.
