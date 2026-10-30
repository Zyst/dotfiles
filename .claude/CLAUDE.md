# Dotfiles — Claude-specific context

@../AGENTS.md

Shared project instructions live in `AGENTS.md`. Shared notes, TODOs, audit prompts, and decision records live in `.agents/`. Keep this file for Claude-specific behavior.

## Memory synchronization

Use Claude's actual per-project memory directory for the current checkout; do not copy a machine-specific project ID into repository instructions. When that memory is configured, mirror shared dotfile facts between it and the appropriate repository file in the same edit, and maintain its `MEMORY.md` index. `AGENTS.md`, `.agents/notes/`, `.agents/todos/`, and `.agents/audits/` remain authoritative across machines and agents. Keep private facts out of repository files.

## Claude Code — fullscreen TUI renderer breaks tmux scrollback (gotcha)

**Symptom:** Scrolling up in tmux copy-mode on a pane running Claude Code shows only the current screen — the previous conversation output is missing from scrollback. Investigated 2026-06-07.

**Root cause (not a dotfile bug):** Claude Code's `fullscreen` TUI renderer draws into the terminal's *alternate-screen buffer* (smcup/rmcup), the same way vim / htop / less do. While an app holds the alternate screen, tmux copy-mode can only see what's currently displayed, never the scrolled-off history — so the conversation backlog is unreachable from tmux. The classic (`default`) renderer prints inline to the main screen, so output accumulates in tmux scrollback normally.

**The `tui` setting** (lives in `~/.claude/settings.json`; also honored in a project `.claude/settings.json`):

- `"default"` — classic inline renderer, scrollback-preserving. **This is Claude Code's default.**
- `"fullscreen"` — flicker-free alt-screen renderer (opt-in research preview).

**How it gets enabled:** running `/tui fullscreen` in-session, which **persists** the `tui` key into `~/.claude/settings.json` and relaunches. Nothing in the tracked dotfiles or any `CLAUDE_CODE_*` env var sets it — so if scrollback suddenly breaks, a stray `/tui fullscreen` is the likely cause. `/tui` with no argument prints the active renderer; `/tui default` switches back (relaunches inline, conversation intact).

**Fix:** run `/tui default`, or set `"tui": "default"` in `~/.claude/settings.json`. To keep fullscreen *and* still read history: `Ctrl+O` (transcript mode) then `[` dumps the conversation into the terminal's native scrollback, where tmux copy-mode can reach it.

**Env-var overrides (verified against Claude Code docs):** `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1` forces the classic renderer regardless of the saved `tui` value (added v2.1.132); `CLAUDE_CODE_NO_FLICKER=1` is the legacy fullscreen toggle. Fullscreen has been opt-in since v2.1.89; the `/tui` command + `tui` setting landed in v2.1.110.

**Why not pinned via home-manager:** considered symlinking `~/.claude/settings.json` from the repo to lock `"tui": "default"`, but **rejected 2026-06-07** — a home-manager `home.file` symlink is read-only, which would also block Claude Code's own in-app writes to that file (`/tui`, and `/config` theme switches, would no longer persist). The file is kept writable and unmanaged; set `tui` locally and rely on this note instead. (`~/.claude/settings.json` and its sibling `settings.local.json` both stay unmanaged so permission acceptances and renderer/theme toggles keep working.)

### Local skills

Reusable Claude Code interaction skills live under `.claude/skills/` in this repo and are symlinked into `$HOME/.claude/skills/` via home-manager (look for the matching `home.file` entry in each `home-*.nix`). They are available to every Claude Code session regardless of working directory.

- **`didactic-upstream-diff-iteration`** (`.claude/skills/didactic-upstream-diff-iteration/SKILL.md`) — one-at-a-time review pattern for upstream-config audits and similar batched-change tasks. Per-candidate Adopt / Decline / Skip prompts, confirm-or-back-out on adopt, persistent rejection list so declined items don't re-surface. Used by `.agents/audits/tmux-upstream-audit/agent-prompt.md`.
