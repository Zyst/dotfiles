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

## Version control: jj on top of git

This repo is **jj-managed** — `.jj/` exists alongside `.git/`, the git remote `origin` (`github.com/Zyst/dotfiles`) is what we push to, but locally we drive everything through jj. Default to `jj` surface commands, **not** `git`, for any work here.

Standard commit-and-push flow:

1. Edit files — jj auto-amends the working-copy change `@` as you save; no `git add` step.
2. `jj describe -m "..."` to set the message on `@`.
3. `jj bookmark move master --to @` to advance the local `master` bookmark onto the new commit.
4. `jj git push --bookmark master` to publish to the git remote.
5. Verify with `jj bookmark list --all` — `master`, `@git`, and `@origin` should all point at the same revision.
6. Optionally `jj new` to start a fresh empty working copy on top (jj will prompt you to do this on the next edit otherwise).

**Why prefer jj over git here:** jj keeps the working copy as a real commit (`@`) with no staging area, and intentionally leaves git's HEAD detached. Running plain `git` against the repo produces confusing or actively harmful output — `git status` reports "Not currently on any branch", and a stray `git commit` would create a commit jj's working copy is unaware of, splitting state across the two tools. The mental model from the default instructions (review diff → message → push) still applies; translate the commands to jj's surface.

**Command translation (jj | git equivalent):**

- `jj st` | `git status`
- `jj diff` | `git diff`
- `jj log` | `git log --oneline`
- `jj describe -m "..."` | `git commit -m "..."` (operates on the working-copy change, not a staged snapshot)
- `jj bookmark move <name> --to @` | (no direct equivalent — git's branch pointer advances implicitly via commit/push)
- `jj git push --bookmark <name>` | `git push origin <name>`
- `jj bookmark list --all` | `git branch -avv`

**Commit-message style:** see recent `jj log` output. Short, lowercase verb start, optional file-prefix (e.g. `.claude/CLAUDE.md: ...`), no `Co-Authored-By:` trailers. The default-instruction trailer convention is overridden here by the local style — match what's already in the log.

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

### Special case — Nvim plugins requiring python3 / ruby providers

`programs.neovim` in `home.nix` / `home-mac.nix` explicitly sets `withPython3 = false; withRuby = false;` (introduced 2026-05-23 as part of the `programs.neovim` adoption). The user's current plugin set doesn't need either provider — but if you add a plugin that relies on `:python3 ...` / `:ruby ...` or declares `if has('python3')`, those calls will fail until you flip the relevant flag back to `true`.

Symptom to watch for: `:checkhealth provider` reporting `provider.python3` or `provider.ruby` as missing AND a plugin you just installed throwing errors referencing those features.

Fix: in `home.nix` AND `home-mac.nix`, change `withPython3 = false;` (or `withRuby = false;`) to `true`, then `home-manager switch`. The wrapper picks up the appropriate `/nix/store/.../nvim-host-python3-…/bin` (or ruby) path on next nvim launch.

Common plugins that need python3: UltiSnips, older YouCompleteMe, denite/defx, some completion sources. Common plugins that need ruby: vim-rails, vim-ruby-refactoring. None of these are in the current `vimrc.org`.

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

## tmux-resurrect failure modes

`tmux-resurrect` + `tmux-continuum` auto-save tmux state every 15 minutes to `~/.local/share/tmux/resurrect/`, with a `last` symlink pointing at the most recent save. Two failure modes present as "tmux is broken at launch" and are worth recognizing before reaching for a heavier fix:

### Empty `last` save → tmux instantly closes on launch

- **Symptom:** Launching `tmux` (or `tmux attach`) from a fresh shell instantly exits, sometimes after a brief `Restoring...` status line in the bottom-right. Under Wayland the same root cause may surface as a TPM "exited with code 1" toast just before the session dies. Confirmed once: 2026-05-24, immediately after a Wayland → X11 switch.
- **Why:** If tmux is killed mid-save (display-server switch, hard logout, continuum auto-save racing a session crash, OOM, etc.), the save file gets truncated to 0 bytes — but `last` has *already* been repointed to it. On next launch, continuum's auto-restore hook reads the empty file, the restore script fails, and the new session unwinds. TPM happens to run in the same startup path, so its non-zero exit is collateral, not the real bug.
- **How to debug:**
  1. `ls -la ~/.local/share/tmux/resurrect/last` — note the symlink target.
  2. `ls -la $(readlink -f ~/.local/share/tmux/resurrect/last)` — check the target's size. 0 bytes = bug.
  3. `ls -la ~/.local/share/tmux/resurrect/ | tail` — find the most recent non-empty `tmux_resurrect_*.txt`. There will usually be one from the previous 15-minute auto-save tick.
- **How to fix (recover from backup, do NOT just wipe):**
  ```
  cd ~/.local/share/tmux/resurrect
  rm last
  ln -s tmux_resurrect_<good-timestamp>.txt last
  rm tmux_resurrect_<empty-timestamp>.txt    # optional, tidies the dir
  ```
  This restores the previous good snapshot; you lose at most one auto-save interval (≤15 min) of state. Verify with `tmux new-session -d -s verify && tmux ls` — the session should stay alive.
- **What does NOT help, so skip these as a first move:** reinstalling all plugins (`prefix + I` / `prefix + alt + u`), clearing `~/.tmux/plugins/`, rebuilding tmux, restarting the display manager. If `last` is the corruption, none of these touch it; if `last` is fine, look elsewhere.

### Stray `pmset: command not found` on Linux

Unrelated but adjacent — tmux-continuum invokes `pmset` (macOS-only) on every interval and on certain hooks, visible as `/bin/bash: line 1: pmset: command not found` in output captured from non-TTY tmux invocations on Linux. Harmless noise. Worth flagging because it shows up in any captured-output debug session and looks alarming; it is not the culprit for startup failures.

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

- `home.nix` — Linux entrypoint and the canonical starting point that the other platform files reference.
- `home-mac.nix` — macOS entrypoint (symlinked into `~/.config/home-manager/home.nix` on this Mac).
- `home-wsl.nix` — WSL entrypoint.

The three files are not `imports`-chained at the Nix level — each is a complete, standalone home-manager config for its platform. But `home.nix` is treated as the **conceptual / manual reference**: improvements made on the Mac side (or elsewhere) are routinely upstreamed back into `home.nix` so it stays the up-to-date baseline for bootstrapping new machines (e.g. WSL is currently behind and needs catch-up). When adding a package or option, decide whether it belongs in `home.nix` (likely to propagate) or only in a platform file.

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

#### Migrate `nvim-compe` → `nvim-cmp`, and `nvim-treesitter` to the new `main` API

- **Status (as of 2026-05-13):** `nvim-treesitter` is pinned to its legacy `master` branch in `~/dev/dotfiles/vimrc.org:888` so the old `require'nvim-treesitter.configs'.setup{}` API still works and `nvim-compe`'s internal `compe_treesitter` source still loads. `nvim-compe` is archived/deprecated by its author in favor of `hrsh7th/nvim-cmp`.
- **Why it matters:** Eventually the `master` branch of `nvim-treesitter` will bitrot and the workaround stops working.
- **How to apply:** Two coupled changes in `vimrc.org`:
  1. Replace the `Plug 'hrsh7th/nvim-compe'` block and `require'compe'.setup{…}` config with `nvim-cmp` + sources (`cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, etc.) and a snippet engine like `LuaSnip`.
  2. Drop the legacy `master` pin on `nvim-treesitter` and migrate the `setup{}` call to the new API — `:TSInstall <langs>` (no more `ensure_installed = "all"` in setup) plus a `FileType` autocmd calling `vim.treesitter.start()`.

  Then: re-tangle → `home-manager switch` → `rm -rf` the affected plugin dirs → `:PlugInstall`. See the vim-plug branch-change note above.

#### Get tmux-resurrect to reattach Claude Code sessions on restore

- **Status:** Long-term, not actively scheduled. Surfaced 2026-05-23.
- **Why:** `tmux-resurrect` (with `tmux-continuum` driving auto-save every 15min) restores window/pane layout and a small whitelist of processes on `prefix + Ctrl-r`, but Claude Code sessions die with the pane. After a restore you get an empty shell where Claude used to be — context lost, conversation gone. If resurrect could be taught to reattach Claude (probably by re-running `claude` with a flag that resumes the most recent session for that working directory, if one exists), session continuity across crashes / reboots / accidental `tmux kill-server` would be much better.
- **How to apply (when picked up):**
  - Investigate resurrect's `@resurrect-processes` option — it accepts a string list of additional binaries to relaunch on restore (e.g. `~vim ~nvim "~claude->claude --resume-last"` style — verify the exact syntax). It's the standard escape hatch for non-default process restoration.
  - Check whether Claude Code has a CLI flag that resumes the latest session for the cwd. If yes, the resurrect process entry can invoke that flag directly. If no, that's a separate ask of the Claude Code team (or work around by recording the session ID into a sidecar file the resurrect hook can read).
  - Decide policy: always reattach (might be jarring if the prior conversation is stale), or reattach only when continuum-restore fires within N minutes of save (continuum saves a timestamp; we can gate on freshness).
  - Sanity-check: does pane content (the visible scrollback) come back via `pane_contents.tar.gz`? If yes, even without true session reattach, the previous transcript is at least visible.
  - Document the final mechanism here once it's wired up so the next reader doesn't have to re-derive it.

#### Wire up nvim LSP properly (Mason install + nvim-lspconfig setup calls)

- **Status (investigated 2026-05-23):** Plumbing is half-installed. `vimrc.org` has `Plug 'neovim/nvim-lspconfig'`, `Plug 'williamboman/mason.nvim'`, and `require("mason").setup()` (~line 1043), but no `lspconfig.<server>.setup{}` calls anywhere — and Mason's packages directory (`~/.local/share/nvim/mason/packages/`) doesn't exist on Mac, meaning no servers were ever actually installed. Net result: zero LSP clients attach to any buffer. nvim-compe's `nvim_lsp = true` source has nothing to draw from; completion is buffer/path/treesitter-only. Also: `:LspInfo` is gone in modern nvim-lspconfig — use `:checkhealth vim.lsp` or `:lua =vim.lsp.get_clients()` instead.
- **Why:** Real LSP (go-to-definition, hover, diagnostics, server-backed completion) is missing across every language. The user noticed while testing autocomplete on `autoload.lua`; it's been broken-by-omission for a while, not a recent regression.
- **How to apply:**
  1. Decide whether to add `Plug 'williamboman/mason-lspconfig.nvim'` (the bridge plugin that auto-installs servers listed in lspconfig + auto-attaches them) — strongly recommended; it makes the rest of the wiring declarative.
  2. Pick a baseline server list. Likely candidates given the languages the user touches: `lua_ls` (vimrc / nvim configs), `tsserver` or `ts_ls` (JS/TS — current name varies by lspconfig version), `pyright` (Python), `gopls` (Go), `rust_analyzer` (Rust), `nil` or `nixd` (Nix), `clojure_lsp` (Clojure — ALE is doing some of this already). Narrow to what's actually in use.
  3. In `vimrc.org`'s LSP section, after `require("mason").setup()`, add `require("mason-lspconfig").setup{ ensure_installed = { ... } }` followed by a default-handler loop or explicit per-server setups, e.g.:
     ```lua
     require("mason-lspconfig").setup_handlers({
       function(server) require("lspconfig")[server].setup{} end,
     })
     ```
  4. Re-tangle (`emacs --batch ...`), `home-manager switch`, then `:MasonInstall` will fire automatically on first nvim launch via mason-lspconfig. Verify with `:checkhealth vim.lsp` — clients should be attached on a Lua / TS / Python buffer.
  5. Consider also adding `cmp-nvim-lsp` once the `nvim-compe → nvim-cmp` migration TODO (above) lands; nvim-compe's LSP source still works but is on the deprecated track.

#### Re-enable OSC-133 prompt navigation for tmux prefix+o / +i / +]

- **Status (investigated 2026-05-23, deferred):** The OSC-133 branch of `tmux.conf` is gated behind `%if $IS_TMUX_3_4_OR_ABOVE`, and `TMUX_VERSION` is built using wincent's stock `#{s|next-||:#{version}}` regex which does NOT strip trailing letter suffixes. On Ubuntu/nixpkgs the version is `3.6a`, so the arithmetic returns 0 and the `%else` branch (`❯`-search fallback) runs. This is **intentional** — the OSC-133 path doesn't navigate correctly under fish+starship right now.
- **Why deferred:** Fish 4.x has an open regression where OSC-133 `;A` (prompt-start) markers are misplaced on multi-line prompts ([fish-shell#10776](https://github.com/fish-shell/fish-shell/issues/10776)). Starship's default prompt IS multi-line, so plain `previous-prompt` / `next-prompt` skip prompts. Tried workaround: `previous-prompt -o` / `next-prompt -o` (navigate by `;C` output markers) — `-o` works backward but `next-prompt -o` doesn't navigate forward even with content available. The `❯`-search fallback works reliably on both Mac and Linux.
- **What we confirmed during the investigation:** tmux 3.4+ DOES capture OSC-133 marks correctly (verified with `/usr/bin/printf '\033]133;A\033\\'` — manual emission navigates fine). Fish 4.7.1 has `$fish_features` empty, so OSC-133 emission *should* be on by default. The bug is on fish's emission side, not tmux's capture side.
- **How to re-enable when fish ships the fix:**
  1. Change `tmux.conf` line ~186 from `%hidden TMUX_VERSION="#{s|next-||:#{version}}"` to `%hidden TMUX_VERSION="#{s|next-||:#{s|[a-z]+$||:#{version}}}"` (adds the letter-suffix strip).
  2. Verify on Linux+fish+starship that `prefix + o` and `prefix + i` navigate cleanly between multi-line prompts.
  3. The `]` block-copy binding's selection geometry assumes A-markers (cursor lands ON the prompt line); if you experimented with `-o` variants, restore the A-marker logic.
  4. Reference commit `9b3202d` (the abandoned strip attempt) and this conversation's debugging notes for prior art.

#### Manage Logseq plugin set + per-plugin settings via home-manager (or confirm Logseq Sync covers it natively)

- **Status:** Not started. Surfaced 2026-05-23 as a follow-on to the queued "delete empty Logseq daily journals" cleanup (which introduces the first concrete plugin — `Cologler/logseq-remove-empty-blocks-typescript`, see global `todos.md` at `~/.claude/projects/-Users-zyst/memory/todos.md`).
- **Why:** Logseq plugins are installed per-app, with state in the graph dir (`<graph>/logseq/`) and/or `~/.logseq/` — all outside `~/dev/dotfiles/`. A fresh machine starts with zero plugins and zero settings, which breaks the rest-of-the-repo posture of "rebuild a machine from the dotfiles repo." **Open question first:** Logseq Sync (separate TODO in global `todos.md`) may already sync `<graph>/logseq/`, in which case this TODO collapses to "verify and document." Worth answering before doing any home-manager work.
- **How to apply:**
  1. Test the Sync path first — install a plugin on the Mac, run Logseq Sync, then on a second machine (or in a sandbox graph) confirm whether the plugin auto-installs with its settings preserved.
  2. If Sync covers it: document the finding here and in `~/.claude/projects/-Users-zyst/memory/todos.md`, then close.
  3. If Sync does NOT cover it: identify which Logseq files are canonical plugin config (likely `<graph>/logseq/config.edn` and parts of `<graph>/logseq/plugins/` — distinguish from cached plugin binaries we don't want to vendor) and wire them into `home.nix` via `home.file."…".source = ${dotfiles}/logseq/…;`, matching how other per-app configs are managed. Decide whether plugin binaries themselves are (a) re-downloaded by Logseq on first run from a synced plugin list, (b) vendored in the repo, or (c) Nix-packaged (unlikely for niche community plugins).
  4. Mirror the resolution back to global `todos.md` so both indexes stay in sync.

#### Extract shared home-manager config into a `common.nix` module

- **Status:** Not started. Audit completed 2026-05-24 — `home.nix` and `home-mac.nix` are ~90% byte-identical. (`home-wsl.nix` is explicitly deferred per user direction; revisit when WSL is next worked on.)
- **Why:** Adding a package, tweaking a `programs.<name>` block, or touching the jj template currently requires editing both files identically; drift between them is a real ongoing cost (WSL is already behind, per the "Per-platform entrypoints" section above). A shared `common.nix` module imported by each platform entrypoint collapses the duplication and makes the platform-specific bits explicit.
- **Concrete differences between `home.nix` and `home-mac.nix` (as of 2026-05-24 audit):**
  - `dotfiles` let-binding path (`/home/zyst/dev/dotfiles` vs `/Users/zyst/dev/dotfiles`).
  - `home.homeDirectory` (`/home/zyst` vs `/Users/zyst`).
  - Linux-only packages: `wl-clipboard`, `xclip`.
  - Linux-only `home.file` entries: `.config/awesome`, `.config/environment.d/10-shell.conf` (SHELL env var), `.xinitrc` (`exec awesome`), `.config/regolith/Xresources`, `.config/regolith/i3/config`.
  - `targets.genericLinux.enable = true;` (Linux only — home-manager option that doesn't exist on Mac).
  - Git credential helper: `libsecret` (Linux) vs `osxkeychain` (Mac).
- **Everything else is byte-identical** — all 25 shared packages, the 8 shared `home.file` entries (kitty / ranger / mpv / espanso / didactic-upstream-diff-iteration / vimrc / bashrc / tmux.conf / .emacs.d / openmw / bat), `extraOutputsToInstall`, `sessionVariables`, `stateVersion`, `username`, `news.display`, and all 12 `programs.*` blocks (including the full jj `templates.draft_commit_description`).
- **Recommended shape:** new `common.nix` as a home-manager module, imported via `imports = [ ./common.nix ]` from each platform entrypoint. Within `common.nix`, derive `dotfiles = "${config.home.homeDirectory}/dev/dotfiles"` from `config.home.homeDirectory` instead of hardcoding — eliminates the per-platform `dotfiles` let-binding entirely (the "Source of truth" section above guarantees the repo always lives at `$HOME/dev/dotfiles`).
- **Resulting platform files:**
  - `home-mac.nix` (~10 lines): `imports = [ ./common.nix ]`, `home.homeDirectory`, `programs.git.settings.credential.helper = [ "osxkeychain" ]`.
  - `home.nix` (~30 lines): `imports = [ ./common.nix ]`, `home.homeDirectory`, Linux-only packages (`wl-clipboard`, `xclip`), Linux-only `home.file` entries (awesome / xinitrc / regolith / environment.d), `targets.genericLinux.enable = true;`, `programs.git.settings.credential.helper = [ "libsecret" ]`.
- **How to apply:**
  1. Write `common.nix` by copying the shared portion from `home-mac.nix` (cleaner starting point — no Linux-only entries to strip). Replace the `let dotfiles = "/Users/zyst/..."` with `let dotfiles = "${config.home.homeDirectory}/dev/dotfiles"`.
  2. Rewrite `home-mac.nix` to the slim shape above.
  3. Rewrite `home.nix` to the slim shape above.
  4. `home-manager switch` on Mac (immediate verification on the current machine). The `~/.config/home-manager/home.nix` symlink (→ `home-mac.nix`) is unchanged; Nix imports follow the symlink target, so `./common.nix` resolves correctly against the repo dir with no bootstrap step changes.
  5. Update the "Per-platform entrypoints" section of this file: the statement "The three files are not `imports`-chained at the Nix level — each is a complete, standalone home-manager config for its platform" is no longer true for Mac+Linux. Note `home-wsl.nix` stays standalone until its own refactor.
  6. Linux side gets exercised next time the user is on that machine. Existing Linux TODOs (e.g. Logseq on Linux, Tailscale below) will exercise the new structure as they land.
- **Risks (small):**
  - The git credential helper must stay only in the per-platform files; if added to `common.nix` too, the list-type merge would concatenate both helpers. Same caution applies to any future option with conflicting values per platform — prefer leaving conflicting options out of `common.nix` entirely, or use `lib.mkForce` in the platform file.
  - `home.packages` (list) and `home.file` (attrset) merge naturally across modules — no extra work needed.
  - WSL is explicitly deferred (per user direction 2026-05-24); `home-wsl.nix` can adopt `common.nix` opportunistically next time someone touches it.
- **Effort estimate:** 30–60 minutes of focused work plus one `home-manager switch` per platform to verify.

### Linux

For long-form / speculative items (Wayland switch, Wayland-native tiling WM, status bar + niceties stack), see `.claude/todos/linux.md`. Short inline items below.

#### Set up Logseq Sync on Linux and verify round-trip with Mac / iOS

- **Status:** Not started. Logseq Sync verified working Mac ↔ iOS as of 2026-05-23 (the Mac-↔-mobile Sync TODO in global `todos.md` at `~/.claude/projects/-Users-zyst/memory/todos.md` has been closed); Linux is the remaining device.
- **Why:** Dotfiles repo ships to Linux (and WSL) — user wants the Logseq graph available on the Linux machine too with the same Sync setup so all devices stay consistent. This TODO lives in the dotfiles repo (rather than purely in global memory) because the Linux side has a real dotfiles component: Logseq is not currently in `home.nix`, so the first step is a home-manager package addition.
- **How to apply:**
  1. Verify the Logseq attribute on the locally-pinned nixpkgs (likely `pkgs.logseq` — confirm via `nix-instantiate --eval -E '(import <nixpkgs> {}).logseq.meta.position'` or by searching the pinned channel). Add it to `home.nix` (the Linux entrypoint / shared base — keep out of `home-mac.nix` if Mac's existing non-Nix install should stay authoritative there). If Logseq isn't packaged for Linux in nixpkgs, fall back to AppImage / Flatpak and document the chosen mechanism here. Avoid imperative installs that don't survive a fresh-machine rebuild.
  2. `home-manager switch`.
  3. Launch Logseq on Linux, sign in with the same account used on Mac / iOS, enable Sync, pull the synced graph.
  4. Round-trip a test edit Linux → Mac (or iOS) and back to confirm both directions before treating this as done.
  5. While on this, opportunistically test the **plugin-sync open question** from the global `todos.md` "Bring Logseq plugin set..." entry: does the `Cologler/logseq-remove-empty-blocks-typescript` plugin (once installed on Mac) auto-appear on Linux after Sync? Answering it here unblocks the plugin-sync TODO.

#### Set up Tailscale on Linux and verify Mac → Linux SSH

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
- **Adjacent:** once the path is settled, consider adding `pkgs.tailscale` to `home.nix` (and `home-mac.nix` if the Mac side ends up using the CLI rather than the GUI binary) so the dotfiles repo at least captures the CLI dependency, even though the daemon itself stays system-level. If the `common.nix` refactor (Generic section above) lands first, add Tailscale there only if both platforms end up using the home-manager CLI; otherwise keep it in the relevant platform file.

### Mac

Short inline items below.

#### Install a Caffeine-style keep-awake tool + tune Mac sleep settings

- **Status:** Not started. Surfaced 2026-05-23.
- **Why:** Mac defaults sleep the display and the system on idle, which interrupts long-running tasks (builds, downloads, training runs, screen-shared meetings) and disrupts remote SSH sessions. Want a "stay awake on demand" toggle plus a baseline sleep policy that's more permissive than Apple's default during active work, without leaving the machine awake 24/7.
- **How to apply:**
  - **Keep-awake tool:** Apple's bundled `caffeinate` CLI is a great primitive (`caffeinate -i` blocks idle sleep, `-d` blocks display sleep, `-t N` time-bounds it) — consider a fish wrapper / alias before installing anything. If a menu-bar toggle is wanted, the original "Caffeine" app is dormant; modern open-source replacements include **KeepingYouAwake** (Homebrew cask: `brew install --cask keepingyouawake`) and **Amphetamine** (Mac App Store). Prefer KeepingYouAwake if it's packageable through home-manager / nix (check `pkgs.keepingyouawake` on the locally-pinned channel); otherwise a Homebrew cask + a documented manual install step.
  - **Sleep tuning:** Inspect current policy via `pmset -g`. Likely adjustments worth considering: `displaysleep` (display blank), `sleep` (system sleep), `disksleep` (spin-down), `tcpkeepalive` (let the Mac stay reachable on the network while asleep), `womp` (wake on LAN), `powernap`. Whatever the final values, capture them as a documented `pmset` invocation here so the policy is reproducible on a new machine.
  - **Decide on scope:** is the policy global (same on AC + battery) or per-source? `pmset` distinguishes `-a` (all), `-c` (charger), `-b` (battery). Long-task wakefulness usually wants `-c` only.

#### Verify terminal notifications surface to macOS Notification Center

- **Status:** Not started. Surfaced 2026-05-23.
- **Why:** Long-running commands, Claude Code prompts, build-finished signals, etc. should be able to ping the user via the native macOS Notification Center instead of relying on the user watching the terminal. Multiple layers could be the producer (Claude Code's own notification setting, `tmux display-message`-style alerts, `terminal-notifier` from a shell hook, Kitty's `OSC 9 / OSC 777` notification escape sequences, fish event hooks, etc.) — but the question this TODO answers is the *plumbing*: do notifications emitted from inside a tmux pane in Kitty actually reach the OS-level notification surface, and is macOS configured to permit it (System Settings → Notifications → Kitty / Terminal / etc.).
- **How to apply:**
  - Quick first probe: from a fish prompt inside tmux+Kitty, fire an OSC 9 escape — `printf '\e]9;hello from terminal\a'` — and see whether macOS pops a notification. If not, repeat from outside tmux to isolate (does tmux block/strip the escape?), then from outside Kitty (does Kitty support OSC 9? It supports OSC 99 / `kitten notify` natively).
  - If Kitty + tmux strip OSC notification escapes, look at `kitten notify` (Kitty's first-class API) and/or `terminal-notifier` as a fallback path. Either can be wired into long-running-command hooks (fish event, shell wrapper, `&& terminal-notifier ...`).
  - macOS side: confirm the emitting app (Kitty) has Notifications permission in System Settings → Notifications. Without this, OS-level surfacing fails silently.
  - Document the final working pattern here and decide whether to make it usable from Claude Code, fish prompt hooks, and ad-hoc shell commands uniformly.

## Related repo conventions

- Per-app config dirs (`alacritty.yml`, `kitty.conf`, `i3.config`, `espanso/`, `mpv/`, `awesome/`, `openmw/`, `BAR/`, etc.) are wired up via home-manager — check the relevant `home*.nix` to see how a given file lands in `$HOME`.
- **X11-era WM configs are semi-abandoned** as of 2026-05-24: `i3.config`, `awesome/`, `Xresources-regolith`, `.xinitrc`. The Linux side is migrating to Sway from-scratch (see `.claude/todos/linux.md`); when porting bindings to the new Sway config, **Regolith's upstream Sway/i3 configs are the canonical reference**, not the local files. Local `i3.config` is consulted only for the Colemak-DH directional bindings (`i3.config:112-116, 171-175`) that Regolith doesn't ship.

### Local skills

Reusable Claude Code interaction skills live under `.claude/skills/` in this repo and are symlinked into `$HOME/.claude/skills/` via home-manager (look for the matching `home.file` entry in each `home-*.nix`). They are available to every Claude Code session regardless of working directory.

- **`didactic-upstream-diff-iteration`** (`.claude/skills/didactic-upstream-diff-iteration/SKILL.md`) — one-at-a-time review pattern for upstream-config audits and similar batched-change tasks. Per-candidate Adopt / Decline / Skip prompts, confirm-or-back-out on adopt, persistent rejection list so declined items don't re-surface. Used by `.claude/agents/tmux-upstream-audit/agent-prompt.md`.
