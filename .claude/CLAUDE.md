# Dotfiles — Claude project context

This file is the portable, machine-independent source of truth for how Claude should work on this repo. Memory under `~/.claude/projects/-Users-zyst/memory/` is per-machine and won't follow this repo to a new laptop — this file does. When setting up a new machine, this is the bootstrap context.

## Sync rule

Whenever a dotfile-related fact is added/updated/removed in user memory (`~/.claude/projects/-Users-zyst/memory/`), mirror the change here in the same edit. The two should not drift. Sections below map roughly 1:1 to memory files; keep the mapping legible.

The reverse also applies: if you update this file with a new dotfiles fact and no memory entry exists yet, add one under `~/.claude/projects/-Users-zyst/memory/` and link it in `MEMORY.md`.

## Path conventions

This repo ships to multiple machines (macOS, Linux, WSL) with different `$HOME` values, hostnames, and project locations. Anything written into a repo-versioned file must use **abstract paths** — `$HOME`, `~`, the `${dotfiles}` Nix let-binding, repo-relative paths, or prose ("Claude's memory directory," "this prompt's sibling file"). Hardcoded `/Users/<name>/...` or machine-specific project IDs do not belong in tracked files (the `let dotfiles = "..."` lines in each `home-*.nix` are the deliberate exception — they're the machine-specific anchor).

Existing references like `~/dev/dotfiles/` are technically machine-specific too and should migrate toward "the dotfiles repo root" phrasing over time.

## Source of truth

- Repo: `https://github.com/Zyst/dotfiles`, cloned to `~/dev/dotfiles/`.
- Managed via Nix + home-manager (`nix-shell` + `home.nix`).
- Files in `$HOME` (`~/.vimrc`, `~/.zshrc`, `~/.config/...`) are read-only symlinks/copies produced by home-manager. **Never edit them directly** — they will be overwritten on the next rebuild, and most are literally read-only.
- When diagnosing: read from `$HOME` (that's the live config), but make the fix in `~/dev/dotfiles/` and cite line numbers from the source.
- When suggesting a tool install, frame it as a home-manager package addition, not `brew install` or similar.

## `home-manager switch` workflow

For most files (non-tangled): edit the source in `~/dev/dotfiles/`, then `home-manager switch` to relink `$HOME`.

### Gotcha — home-manager's own config

home-manager reads from `~/.config/home-manager/home.nix`, **not** directly from `~/dev/dotfiles/`. On the current Mac that path is a symlink to `~/dev/dotfiles/home-mac.nix` (set up 2026-05-13), so edits propagate automatically.

If `home-manager switch` appears to no-op changes you made to `home.nix` / `home-mac.nix`, check:

```
ls -la ~/.config/home-manager/home.nix
```

If it is a regular file (not a symlink), it's a stale copy and must be re-linked. On a fresh machine this symlink needs to be created — pick the right source (`home.nix`, `home-mac.nix`, `home-wsl.nix`) for the platform.

### Special case — `vimrc` (org-babel tangled)

`~/.vimrc` is tangled from `~/dev/dotfiles/vimrc.org`. `home-manager switch` does **not** re-tangle — it just symlinks the committed `.vimrc`. The full flow is three steps:

1. Edit `~/dev/dotfiles/vimrc.org` (the org source, not the tangled `.vimrc`).
2. Re-tangle:
   ```
   cd ~/dev/dotfiles && command emacs --batch --eval "(progn (require 'org) (find-file \"vimrc.org\") (org-babel-tangle))"
   ```
   (Use `command emacs` to bypass the bashrc alias `emacs="emacs -nw -a \"\""`, which prepends emacsclient-style flags that break the main binary's batch mode.)
3. `home-manager switch` to publish the new `.vimrc` into the Nix store and update the `~/.vimrc` symlink.

### Special case — vim-plug plugin branch/version changes

vim-plug does **not** auto-switch the branch of an already-checked-out plugin when you change the `Plug` line. After steps 1–3 above, also:

```
rm -rf ~/.config/nvim/plugged/<plugin>
nvim --headless '+PlugInstall --sync' '+qa'    # run from a valid cwd like ~
```

## Voice and tone for comments / documentation

Two audiences read this repo, with different expectations:

**Human-facing files** — `vimrc.org`, `tmux.conf`, `home.nix` / `home-mac.nix` / `home-wsl.nix`, `config.fish`, `kitty.conf`, `bashrc`, the various per-app config dirs, `README.md`. These belong to the user and stay visible while editing. When adding comments or prose, **read a few surrounding paragraphs first and match their voice**. The user has spotted tone-mismatch before and asked for rewrites, so this is a real concern, not cosmetic.

- `vimrc.org` is light and chatty — "We enable X for Y", "We also want Z", short sentences, occasional first-person plural. A multi-bullet block with bolded **Field:** labels stands out as alien.
- `tmux.conf` is one-or-two-line comments, often self-referential ("`^space ^space` is awfully close to..."). Multi-paragraph technical justifications belong elsewhere (e.g., here in CLAUDE.md).
- `home*.nix` is largely code-only — no comments at all in long stretches. Don't introduce explanatory comments just because a change feels non-obvious; if the code itself is clear, leave it.
- If a thorough explanation is genuinely needed but doesn't fit the local voice, keep the inline note short and put the depth in `.claude/CLAUDE.md` (or a `.claude/todos/*.md` file), then link from the inline comment.

**`.claude/` files** — `CLAUDE.md`, `todos/*.md`, `agents/*/agent-prompt.md`, `skills/*/SKILL.md`. These are for AI agents (Claude and others), not for humans to read at editing time. **Verbosity, dense bold-field structure, and exhaustive context are *helpful* here** because they get re-read fresh by an LLM each session. Match the existing dense `.claude` template (e.g., **Status:** / **Why:** / **How to apply:** triads for TODOs); don't trim or "humanize" these the way you would a `vimrc.org` comment. Same repo, different reader, different rules.

## tmux.conf upstream reference

`~/dev/dotfiles/tmux.conf` is **heavily lifted from wincent/wincent**: <https://github.com/wincent/wincent/blob/main/aspects/dotfiles/files/.config/tmux/tmux.conf>

Spot-check on 2026-05-21: 73 of the first 180 lines are byte-identical (same prefix `C-Space`, same vim-tmux-navigator block, same `#{pane_current_path}` splits, same SHLVL-reset, same `❯`-search prompt bindings, etc.). Treat wincent's file as the canonical upstream — check it **first** when making tmux changes for an existing pattern.

Patterns the user hasn't yet adopted but may want to:

- **`o`/`i` prompt-navigation pair** (wincent's lines 384-428): `[o]ut` back / `[i]n` forward. Has both an OSC-133 native path (`send-keys -X previous-prompt`/`next-prompt`, tmux 3.4+) and a `❯`-search fallback. `-r` on the `-T copy-mode-vi` variants lets you tap repeatedly without re-pressing prefix.
- **`{}` block syntax** everywhere — wincent never uses `\;` chains. Avoids parser quirks that bite `\;`-chained bindings (e.g. `list-keys` rendering them as `\;\;` after TPM loads).
- **Version gating with `%hidden`**: `%hidden IS_TMUX_3_4_OR_ABOVE="#{e|>=|f|0:$TMUX_VERSION,3.4}"` enables `%if $IS_TMUX_3_4_OR_ABOVE` preprocessor blocks. Requires tmux 3.2+.
- **Vim-style VISUAL / VISUAL_LINE / VISUAL_BLOCK in copy-mode** (lines 204-261) with `@mode` option tracking.
- **`set-hook -g pane-mode-changed`** for reacting to copy-mode transitions.
- **Naked `/` and `?` from normal mode** (lines 439-450): drop into copy-mode AND start a search in one go.
- **Pane border showing copy-mode indicator + search count** (lines 277-328).

When borrowing, keep the borrowed code recognizable (similar comments and structure) so the lineage stays visible.

## home-manager options reference

Gold-standard reference: <https://nix-community.github.io/home-manager/options.xhtml>

Consult this **before** editing `home.nix` / `home-mac.nix` / `home-wsl.nix`. It tracks deprecations and renames invisible to training-data memory (e.g., `programs.jujutsu.enableFishIntegration` was removed once shell integration became automatic).

Guidelines:

1. Prefer first-class `programs.<name>` modules (with `enable`, `settings`, integration toggles) over `home.packages` + hand-written `home.file."..."` config.
2. When in doubt, verify the option exists on the locally-pinned channel:
   ```
   nix-instantiate --eval -E '(import <home-manager/modules> { configuration = { ... }: { home.username = "x"; home.homeDirectory = "/x"; home.stateVersion = "22.05"; }; pkgs = import <nixpkgs> {}; }).options.programs.<name>'
   ```
3. If the docs page and the local channel disagree, trust the local channel (that's what `home-manager switch` evaluates against) and surface the discrepancy.

## Per-platform entrypoints

- `home.nix` — Linux entrypoint and the shared base that the other platform files build on.
- `home-mac.nix` — macOS entrypoint (symlinked into `~/.config/home-manager/home.nix` on this Mac).
- `home-wsl.nix` — WSL entrypoint.

When adding a package or option, decide whether it belongs in the shared `home.nix` or a platform file.

## Open dotfile-related TODOs

Grouped by applicability. **Generic** = repo-wide items that affect the shared config (vimrc.org, tmux.conf, home-manager idioms) regardless of platform. **Linux** and **Mac** = platform-specific items.

For Linux, the long-form prose for big/speculative items (Wayland switch, tiling WM choice, status bar stack) lives at `.claude/todos/linux.md`. Add new platform-specific entries to that file (and link from the Linux subsection here) when they're too involved to inline. Mac would follow the same convention if/when it accumulates similar items.

### Generic

#### Audit upstream wincent `tmux.conf` for new / polished patterns via didactic-upstream-diff-iteration

- **Status:** Not started. Audit prompt lives at the repo-relative path `.claude/agents/tmux-upstream-audit/agent-prompt.md`; rejection state at the sibling `rejected.md`.
- **Why:** `tmux.conf` is heavily lifted from `wincent/wincent` (see "tmux.conf upstream reference" above), and there are known unadopted patterns — but new bindings compete with muscle memory, so each candidate needs to be tested individually before it stays. The audit drives the `didactic-upstream-diff-iteration` skill over a seeded candidate list (one-at-a-time review, no bulk import).
- **How to apply:** Open the agent prompt at `.claude/agents/tmux-upstream-audit/agent-prompt.md` and ask Claude to follow it. The first instruction in that prompt is to load the `didactic-upstream-diff-iteration` skill (symlinked into `$HOME/.claude/skills/` via home-manager); the skill then walks the seeded "Pending candidates" section one entry at a time. Declines land in `./rejected.md` so they don't re-surface on later runs.

#### Vendor `wincent/wincent` as an upstream subrepo + add an auto-sync skill

- **Status:** Not started. We currently reference wincent's configs by raw GitHub URL on each audit.
- **Why:** A local checkout (e.g. under a repo-relative `upstream/wincent/` path — mechanism TBD: git submodule, git subtree, or `git-subrepo`) would let `rg`, `git log`, and the existing audit tooling work against it for fast diffs, make the upstream readable offline, and let us pin to a known commit and bump deliberately instead of racing whatever `main` is on each `WebFetch`. A companion **sync skill** keeps the checkout fresh on demand so it doesn't go stale silently.

  **Important caveat to encode once vendored — authority vs. staleness:** treat wincent's repo as an authoritative source *only for tools wincent still actively uses.* If he has moved off a tool (e.g. changed terminals, dropped a plugin, switched window manager), the file we'd be referencing is a fossil — less trustworthy than internal experimentation or current web sources. Before treating any wincent file as canonical, do a recency check on his recent commits / activity for that file; if it hasn't been touched in a long time, or his current configs reference a different replacement, downgrade its authority and prefer internal/web sources.

- **How to apply:**
  1. Pick the vendoring mechanism (submodule is simplest; subtree avoids the `.gitmodules` dance and keeps clones single-step). Vendor `wincent/wincent` under a repo-relative path like `upstream/wincent/`.
  2. Build a new skill (likely `.claude/skills/sync-upstream-wincent/SKILL.md`) that performs an on-demand fetch + fast-forward (or merge), reports what changed since the last sync, and highlights diffs that touched files we mirror locally (`tmux.conf` first; later anything else we borrow from).
  3. Add the authority-vs-staleness rule to `.claude/CLAUDE.md` (probably under the existing "tmux.conf upstream reference" section, generalized): when consulting a vendored upstream file, check the file's recent commit activity first; if it looks abandoned, treat it as a historical reference rather than canonical.
  4. Once vendored, repoint `.claude/agents/tmux-upstream-audit/agent-prompt.md` at the local checkout instead of the GitHub URL — the audit gets faster and works offline.

#### Run the home-manager idiomaticity audit on `home.nix` / `home-mac.nix`

- **Status:** Not started. Audit brief lives at `/Users/zyst/ai-notes/home-manager-audit/agent-prompt.md`.
- **Why:** Both configs have grown organically — packages in `home.packages` and configs via `home.file."…".source` — without consistently reaching for first-class `programs.<name>` modules. The audit produces a ranked, read-only report (High/Medium/Low findings) the user can apply selectively.
- **How to apply:** Dispatch a general-purpose `Agent` with the brief at `~/ai-notes/home-manager-audit/agent-prompt.md`. Read-only — does **not** edit files or run `home-manager switch`. Scope is strictly the two `.nix` files; do NOT let it propose changes to referenced dotfiles (`config.fish`, `kitty.conf`, `tmux.conf`, `vimrc.org`, etc.) — those are deferred-pending-scope-expansion. Each finding must cite a specific home-manager option from <https://nix-community.github.io/home-manager/options.xhtml> and be verified against the local channel via `nix-instantiate --eval`. After the report lands, surface High-impact findings (especially deprecations) for the user to decide on; don't auto-apply.

#### Migrate `nvim-compe` → `nvim-cmp`, and `nvim-treesitter` to the new `main` API

- **Status (as of 2026-05-13):** `nvim-treesitter` is pinned to its legacy `master` branch in `~/dev/dotfiles/vimrc.org:888` so the old `require'nvim-treesitter.configs'.setup{}` API still works and `nvim-compe`'s internal `compe_treesitter` source still loads. `nvim-compe` is archived/deprecated by its author in favor of `hrsh7th/nvim-cmp`.
- **Why it matters:** Eventually the `master` branch of `nvim-treesitter` will bitrot and the workaround stops working.
- **How to apply:** Two coupled changes in `vimrc.org`:
  1. Replace the `Plug 'hrsh7th/nvim-compe'` block and `require'compe'.setup{…}` config with `nvim-cmp` + sources (`cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, etc.) and a snippet engine like `LuaSnip`.
  2. Drop the legacy `master` pin on `nvim-treesitter` and migrate the `setup{}` call to the new API — `:TSInstall <langs>` (no more `ensure_installed = "all"` in setup) plus a `FileType` autocmd calling `vim.treesitter.start()`.

  Then: re-tangle → `home-manager switch` → `rm -rf` the affected plugin dirs → `:PlugInstall`. See the vim-plug branch-change note above.

#### Re-enable OSC-133 prompt navigation for tmux prefix+o / +i / +]

- **Status (investigated 2026-05-23, deferred):** The OSC-133 branch of `tmux.conf` is gated behind `%if $IS_TMUX_3_4_OR_ABOVE`, and `TMUX_VERSION` is built using wincent's stock `#{s|next-||:#{version}}` regex which does NOT strip trailing letter suffixes. On Ubuntu/nixpkgs the version is `3.6a`, so the arithmetic returns 0 and the `%else` branch (`❯`-search fallback) runs. This is **intentional** — the OSC-133 path doesn't navigate correctly under fish+starship right now.
- **Why deferred:** Fish 4.x has an open regression where OSC-133 `;A` (prompt-start) markers are misplaced on multi-line prompts ([fish-shell#10776](https://github.com/fish-shell/fish-shell/issues/10776)). Starship's default prompt IS multi-line, so plain `previous-prompt` / `next-prompt` skip prompts. Tried workaround: `previous-prompt -o` / `next-prompt -o` (navigate by `;C` output markers) — `-o` works backward but `next-prompt -o` doesn't navigate forward even with content available. The `❯`-search fallback works reliably on both Mac and Linux.
- **What we confirmed during the investigation:** tmux 3.4+ DOES capture OSC-133 marks correctly (verified with `/usr/bin/printf '\033]133;A\033\\'` — manual emission navigates fine). Fish 4.7.1 has `$fish_features` empty, so OSC-133 emission *should* be on by default. The bug is on fish's emission side, not tmux's capture side.
- **How to re-enable when fish ships the fix:**
  1. Change `tmux.conf` line ~186 from `%hidden TMUX_VERSION="#{s|next-||:#{version}}"` to `%hidden TMUX_VERSION="#{s|next-||:#{s|[a-z]+$||:#{version}}}"` (adds the letter-suffix strip).
  2. Verify on Linux+fish+starship that `prefix + o` and `prefix + i` navigate cleanly between multi-line prompts.
  3. The `]` block-copy binding's selection geometry assumes A-markers (cursor lands ON the prompt line); if you experimented with `-o` variants, restore the A-marker logic.
  4. Reference commit `9b3202d` (the abandoned strip attempt) and this conversation's debugging notes for prior art.

### Linux

For long-form / speculative items (Wayland switch, Wayland-native tiling WM, status bar + niceties stack), see `.claude/todos/linux.md`. Short inline items below.

#### Install Mono Lisa, and validate it's picked up

### Mac

#### Install Mono Lisa, and validate it's picked up

## Related repo conventions

- Per-app config dirs (`alacritty.yml`, `kitty.conf`, `i3.config`, `espanso/`, `mpv/`, `awesome/`, `openmw/`, `BAR/`, etc.) are wired up via home-manager — check the relevant `home*.nix` to see how a given file lands in `$HOME`.

### Local skills

Reusable Claude Code interaction skills live under `.claude/skills/` in this repo and are symlinked into `$HOME/.claude/skills/` via home-manager (look for the matching `home.file` entry in each `home-*.nix`). They are available to every Claude Code session regardless of working directory.

- **`didactic-upstream-diff-iteration`** (`.claude/skills/didactic-upstream-diff-iteration/SKILL.md`) — one-at-a-time review pattern for upstream-config audits and similar batched-change tasks. Per-candidate Adopt / Decline / Skip prompts, confirm-or-back-out on adopt, persistent rejection list so declined items don't re-surface. Used by `.claude/agents/tmux-upstream-audit/agent-prompt.md`.
