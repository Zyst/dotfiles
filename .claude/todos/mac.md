# Mac-specific dotfile TODOs

Long-form list of macOS-only exploration tasks that don't yet warrant inlining in `.claude/CLAUDE.md`. The CLAUDE.md "Open dotfile-related TODOs → Mac" section is the index; this file is the prose.

When to consult this file:
- Bootstrapping a fresh Mac and deciding which window management / tooling stack to use.
- Considering platform-specific tooling that has no Linux equivalent or differs meaningfully (SIP-gated APIs, Apple Silicon quirks).
- Tracking experiments the user is curious about but hasn't committed to yet.

Items here are speculative; do not implement without asking. None of these are committed direction — they're explore-and-decide entries.

## Pick a tiling window manager

- **Status:** Not started. Currently relying on stock macOS window management (manual drag/Mission Control) plus whatever keyboard snapping Apple ships natively.
- **Why:** The vim + tmux workflow this repo is built around is keyboard-driven; reaching for the trackpad to arrange windows is a constant context switch. Tiling WMs eliminate that, and on a multi-monitor Mac the win is bigger than on a single laptop screen. The Linux side of this repo has long used i3 / awesome — there's existing muscle memory to lean on.
- **Why not yet:** macOS doesn't ship a tiling WM and the third-party landscape has a real trade-off axis: the most powerful options require disabling SIP (System Integrity Protection), which is a security posture change worth thinking about deliberately. Newer SIP-free options exist but are younger and less battle-tested.
- **Candidate options:**
  - **yabai** — most mature, scriptable, supports true window movement and space manipulation. Full feature set requires **disabling SIP** (partially) to load the scripting addition. Without SIP changes it still works but loses focus-follows-mouse, window movement across spaces, and some layout commands. Pair with **skhd** for keybindings.
  - **AeroSpace** — i3-inspired, **no SIP changes required**. Uses virtual workspaces (its own concept, decoupled from macOS Spaces) to sidestep the APIs yabai needs SIP for. Active development, growing community. Lowest-friction option if SIP-disable is off the table.
  - **Amethyst** — older, declarative auto-tiling (Xmonad-style). No SIP changes. Less powerful than yabai or AeroSpace but very stable; reasonable if a minimal "just tile what's open" model is enough.
  - **Rectangle / Rectangle Pro** — not actually tiling; keyboard-driven window snapping. Mention only to rule out — it's the conservative fallback if none of the above stick.
- **How to approach:** Decide the SIP question first — if disabling SIP is unacceptable, yabai's full feature set is off the table and the real choice is AeroSpace vs. Amethyst (likely AeroSpace given the i3 lineage). If SIP-disable is acceptable, yabai+skhd is the most-capable answer but carries ongoing maintenance cost (the scripting addition has to be re-signed/reloaded after macOS updates). Install via home-manager (`programs.aerospace` exists; yabai and skhd are available as packages with `services.<name>` modules). Keybindings should aim to coexist with tmux's prefix and the existing vim leader to avoid collisions.

## Status bar + desktop niceties for a tiling WM setup

- **Status:** Not started. Only relevant after committing to a tiling WM above.
- **Why:** macOS's menu bar stays put with any of these WMs, but a tiling workflow benefits from a richer status surface (workspace indicators, focused-window title, custom widgets) that the stock menu bar doesn't provide. yabai and AeroSpace both expect you to bring your own.
- **Candidate stack:**
  - Status bar: **SketchyBar** — the de-facto choice for yabai/AeroSpace setups; highly customizable, can render workspace indicators and arbitrary scripts. Pairs well with either WM.
  - Launcher: **Raycast** (closed-source but free, excellent UX) or **Alfred** (longer-standing). Either replaces Spotlight.
  - Hotkey daemon: only needed for yabai (**skhd**); AeroSpace ships its own.
- **How to approach:** Decide the full stack at once — SketchyBar's workspace widget is WM-specific, so it has to be configured against whichever WM you pick. Don't piecemeal.
