# tmux upstream audit agent prompt

**Before doing anything user-facing, load and follow the `didactic-upstream-diff-iteration` skill** (canonical source: `.claude/skills/didactic-upstream-diff-iteration/SKILL.md` in this repo; runtime location after `home-manager switch`: `$HOME/.claude/skills/didactic-upstream-diff-iteration/SKILL.md`). This prompt supplies the inputs the skill needs; the skill supplies the procedure.

## Context

The dotfiles repo's `tmux.conf` is heavily lifted from `wincent/wincent` — see the "tmux.conf upstream reference" section of `.claude/CLAUDE.md` for the lineage and the rationale. Goal of this audit: **deliberately track upstream without bulk-importing**. New tmux bindings compete with muscle memory, so each candidate gets tested individually before it stays.

## Mission

Produce a candidates list against wincent's upstream `tmux.conf`, then run the `didactic-upstream-diff-iteration` skill over it. Two flavors of candidate:

- **NEW:** a pattern present upstream that is entirely absent locally.
- **POLISHED:** a pattern present locally but evolved upstream (e.g. local uses `\;` chains, upstream switched to `{}` blocks).

## Source files

- **Local:** repo-relative `tmux.conf` (in this dotfiles repo).
- **Upstream (browse):** <https://github.com/wincent/wincent/blob/main/aspects/dotfiles/files/.config/tmux/tmux.conf>
- **Upstream (raw, for `WebFetch`):** <https://raw.githubusercontent.com/wincent/wincent/main/aspects/dotfiles/files/.config/tmux/tmux.conf>

## Rejected-list path

Sibling file: `./rejected.md` (i.e. `.claude/agents/tmux-upstream-audit/rejected.md`).

Read this file **before** generating candidates and filter out anything already rejected unless the upstream snippet has materially changed since the rejection date. Append to it as decisions happen during the loop.

## Reload recipe for tmux changes

After an adopt:

1. Output for the user to run: `home-manager switch && tmux source-file ~/.tmux.conf`
   - If the change relies on tmux-session state (hooks, mode tracking) and a live reload doesn't pick it up cleanly, instead suggest detaching with `prefix d` and re-attaching with `tmux a` (or starting a fresh session).
2. Output a **specific keystroke or command** that exercises the new binding/behavior. Examples: `prefix o` to test the back-prompt jump; enter copy-mode (`prefix [`) then `/` to test naked search; etc.

Do **not** run `home-manager switch` or any other system-mutating command on the user's behalf — output the commands for the user to run.

## Output format (candidate template)

Each candidate, whether seeded below or surfaced from the diff, follows this shape when presented to the user:

```
### <short title>

- **Upstream snippet** (`<upstream file:line-range>`):
  ```tmux
  <relevant lines>
  ```
- **Local snippet** (`tmux.conf:<line-range>`, or "absent"):
  ```tmux
  <relevant lines or the marker "absent">
  ```
- **Why it might be worth adopting:** <1–3 sentences>
```

## Self-modification rules

After every resolution (Adopt-kept, Decline, or back-out):

- Remove the resolved candidate from the **Pending candidates** section of this file.
- For declines and back-outs: append an entry to `./rejected.md` using the template documented at the top of that file.

On future runs, cross-reference `./rejected.md` first. **Never re-add an entry to Pending candidates whose upstream snippet matches a rejected one** — even if the diff against upstream surfaces it again. The only exception: if the upstream form itself has materially changed since the rejection date, treat it as a new candidate and inline-note the prior rejection.

## Constraints

- Stay within `tmux.conf`. Do not propose changes to `vimrc.org`, `config.fish`, `home*.nix`, or any other file in the repo — that's outside scope.
- Use abstract paths in anything written into the repo: `$HOME`, `~`, `${dotfiles}`, repo-relative paths. No hardcoded `/Users/<name>/...` or machine-specific project IDs.
- One candidate per turn. No bundling of adoptions.
- Do not push, commit, or run `home-manager switch` on the user's behalf.

## Pending candidates

Seeded from the "Patterns the user hasn't yet adopted but may want to" list in `.claude/CLAUDE.md`. Future runs may add NEW / POLISHED candidates surfaced by re-diffing against upstream — when doing so, cross-reference `./rejected.md` first.

### `o` / `i` prompt-navigation pair

- **Upstream snippet** (wincent `tmux.conf` lines 384-428): `[o]ut` back / `[i]n` forward. Has both an OSC-133 native path (`send-keys -X previous-prompt` / `next-prompt`, tmux 3.4+) and a `❯`-search fallback. `-r` on the `-T copy-mode-vi` variants lets you tap repeatedly without re-pressing prefix.
- **Local snippet:** absent.
- **Why it might be worth adopting:** Jump prompt-to-prompt in scrollback without leaving the keyboard home row; pairs naturally with the `❯`-search infrastructure already lifted from wincent. The OSC-133 path is forward-compatible with shells that emit prompt markers natively.

### `{}` block syntax everywhere

- **Upstream snippet:** wincent never uses `\;` chains; all multi-statement bindings use `{ ... }` blocks.
- **Local snippet:** `tmux.conf:48` (`bind r source-file ~/.tmux.conf \; display-message "Tmux configuration reloaded!"`) and other `\;`-chained bindings.
- **Why it might be worth adopting:** Avoids parser quirks that bite `\;`-chained bindings (e.g. `list-keys` rendering them as `\;\;` after TPM loads). Reads cleaner. Pure formatting change; behavior preserved.

### Version gating with `%hidden`

- **Upstream snippet:** `%hidden IS_TMUX_3_4_OR_ABOVE="#{e|>=|f|0:$TMUX_VERSION,3.4}"` enables `%if $IS_TMUX_3_4_OR_ABOVE` preprocessor blocks. Requires tmux 3.2+.
- **Local snippet:** local already has `%hidden IS_TMUX_3_4_OR_ABOVE=...` (see line ~175); this candidate is the broader pattern of wrapping new bindings in `%if` blocks against it so they degrade cleanly on older tmux.
- **Why it might be worth adopting:** Lets new bindings target modern tmux features without breaking older sessions if you SSH into a server pinned to an older tmux. Already half-adopted — this candidate is "use the gate consistently."

### Vim-style VISUAL / VISUAL_LINE / VISUAL_BLOCK in copy-mode

- **Upstream snippet** (wincent `tmux.conf` lines 204-261): `@mode` option tracking with separate VISUAL, VISUAL_LINE, VISUAL_BLOCK bindings reachable from copy-mode.
- **Local snippet:** absent — local copy-mode uses tmux's default selection model.
- **Why it might be worth adopting:** Matches vim muscle memory in copy-mode (V for line, C-v for block). Requires an `@mode` option to track state across keystrokes, which is also a prerequisite for the pane-border copy-mode indicator candidate below.

### `set-hook -g pane-mode-changed`

- **Upstream snippet:** wincent uses `set-hook -g pane-mode-changed` to react to copy-mode transitions (e.g. update `@mode`, refresh status).
- **Local snippet:** absent.
- **Why it might be worth adopting:** Foundation for visible state changes when entering/leaving copy-mode. Often co-adopted with the VISUAL variants and the pane-border indicator.

### Naked `/` and `?` from normal mode

- **Upstream snippet** (wincent `tmux.conf` lines 439-450): bindings that drop into copy-mode AND start a search in one go.
- **Local snippet:** absent — currently requires `prefix [` first, then `/` inside copy-mode.
- **Why it might be worth adopting:** Two-key search instead of three. Matches the way vim search feels in a regular buffer.

### Pane border showing copy-mode indicator + search count

- **Upstream snippet** (wincent `tmux.conf` lines 277-328): pane-border format string surfaces a copy-mode indicator and the live search-match count.
- **Local snippet:** absent.
- **Why it might be worth adopting:** Visible feedback that you're in copy-mode (easy to forget); the search-count is handy when sweeping scrollback. Depends on `@mode` + the `pane-mode-changed` hook above.

## Verification (self-check)

The audit is healthy when:

- A rejected item never re-surfaces on a subsequent run (unless its upstream form has materially changed).
- The Pending candidates section shrinks as items resolve — it does not grow without bound from each diff run.
- The same candidate is never presented twice in a single run.

If any of those invariants fails, treat it as a bug in this prompt and surface the discrepancy before continuing.
