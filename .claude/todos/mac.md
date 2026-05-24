# macOS-specific dotfile TODOs

Canonical list of macOS-only TODOs. See sibling files for other scopes:

- `todos.md` — generic / cross-platform dotfile TODOs
- `linux.md` — Linux-specific

Memory's `~/.claude/projects/-Users-zyst/memory/todos.md` mirrors items per the sync rule in CLAUDE.md, but **this file is the canonical, in-repo source** — it survives an OS hop, while memory is per-machine.

When picking an item, walk it didactically (one change at a time, adopt/decline, test, commit). Done items get deleted from this file outright — see the `feedback_todo_deletion.md` memory entry for the rule.

---

## Install a Caffeine-style keep-awake tool + tune Mac sleep settings

- **Status:** Not started. Surfaced 2026-05-23.
- **Why:** Mac defaults sleep the display and the system on idle, which interrupts long-running tasks (builds, downloads, training runs, screen-shared meetings) and disrupts remote SSH sessions. Want a "stay awake on demand" toggle plus a baseline sleep policy that's more permissive than Apple's default during active work, without leaving the machine awake 24/7.
- **How to apply:**
  - **Keep-awake tool:** Apple's bundled `caffeinate` CLI is a great primitive (`caffeinate -i` blocks idle sleep, `-d` blocks display sleep, `-t N` time-bounds it) — consider a fish wrapper / alias before installing anything. If a menu-bar toggle is wanted, the original "Caffeine" app is dormant; modern open-source replacements include **KeepingYouAwake** (Homebrew cask: `brew install --cask keepingyouawake`) and **Amphetamine** (Mac App Store). Prefer KeepingYouAwake if it's packageable through home-manager / nix (check `pkgs.keepingyouawake` on the locally-pinned channel); otherwise a Homebrew cask + a documented manual install step.
  - **Sleep tuning:** Inspect current policy via `pmset -g`. Likely adjustments worth considering: `displaysleep` (display blank), `sleep` (system sleep), `disksleep` (spin-down), `tcpkeepalive` (let the Mac stay reachable on the network while asleep), `womp` (wake on LAN), `powernap`. Whatever the final values, capture them as a documented `pmset` invocation here so the policy is reproducible on a new machine.
  - **Decide on scope:** is the policy global (same on AC + battery) or per-source? `pmset` distinguishes `-a` (all), `-c` (charger), `-b` (battery). Long-task wakefulness usually wants `-c` only.
