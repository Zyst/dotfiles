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

#### Home-manager idiomaticity audit — mid-walk

- **Status (as of 2026-05-23):** Audit was run and a ranked report produced (18 findings — 3 High, 8 Medium, 7 Low + 1 structural). All Mac-actionable findings walked one at a time using `didactic-upstream-diff-iteration` principles. **Walk is effectively complete on Mac.** Only L5 (`environment.d` investigation — Linux-only, not testable from Mac) and the structural `common.nix` refactor (intentionally deferred — too large for short sessions) remain.
- **Source of truth files (in-repo so they survive an OS hop):**
  - `.claude/agents/home-manager-audit/agent-prompt.md` — original audit brief.
  - `.claude/agents/home-manager-audit/report.md` — full ranked findings.
  - `.claude/agents/home-manager-audit/state.md` — iteration state (Pending / Adopted / Declined / no-op confirmations). Authoritative for what's been decided.
- **Adopted (2 of 14 actionable findings):** H2 (`programs.gh` + scoped credential helper, commit `8f747340`); M4 (`programs.neovim` + node-only providers, commit `6ea486fe`).
- **Declined (12 — reasoning per-finding lives in `state.md`):** H1 bat, H3 eza, M1 htop, M2 jq, M3 ripgrep, M5 tmux, M6 fastfetch, M7 yt-dlp, M8 ranger (clash-tested), L3 fzf.enableFishIntegration (kept explicit), L4 fzf tmux popup (tested-then-rolled-back).
- **Why declines pattern:** the user prefers `pkgs.X` + raw `home.file` for tools used across non-Nix environments (servers, ssh hosts) — the literal form is closer to what they'd write by hand on bootstrap. Small `programs.X.enable`-only swaps with no other behavioral change generally fall to this reasoning.
- **Side-finding from L4 worth remembering:** any home-manager option that adds to `home.sessionVariables` won't propagate to running terminal sessions because of the `__HM_SESS_VARS_SOURCED` re-source guard in `hm-session-vars.fish`. Full terminal-emulator restart (not just tmux) is required for new env vars to appear in existing sessions.
- **How to resume L5 / common.nix:** read `state.md`. For L5 (Linux-only), boot Linux and check whether enabling `home.shell.enableShellIntegration` makes the manual `.config/environment.d/10-shell.conf` redundant. For `common.nix`, schedule a dedicated session — it's a multi-file refactor with cross-platform implications.

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

#### Verify zoxide works on Linux

- **Status:** Installed and verified working on Mac (2026-05-23). `programs.zoxide = { enable = true; enableFishIntegration = true; };` landed in both `home.nix` and `home-mac.nix`. Live-tree check confirmed both options exist and are `visible` (the `enableFishIntegration` option had not collapsed to automatic at the time of adoption — defaults to `true` but kept explicit per the L3 reasoning pattern).
- **Why:** Mac confirmed `z <partial>` jumps to frecency-ranked dir and `zi` opens an interactive picker. Linux side hasn't been retested since the config landed.
- **How to apply:** Next time you're on Linux: `home-manager switch`, then in a fresh fish session, `cd` around a few dirs to seed the database, then verify `z <partial>` jumps and `zi` opens an interactive picker. If anything's broken on Linux specifically (e.g. fish version mismatch, fzf path divergence affecting `zi`), capture findings here.
- **Open style decision (parked):** whether to alias `cd` to `z` (some users do, some keep them distinct). Current default: keep distinct — `z` for smart, `cd` for explicit.

#### Enable the jujutsu module in starship

- **Status (investigated 2026-05-23):** Starship 1.25.1 ships a jujutsu module, but it is **opt-in** — the default `format = "$all"` does not include `$jujutsu_*` modules, and the user has no `~/.config/starship.toml`. Net result: starship shows git info in jj-colocated repos but nothing about the jj change-id / bookmark / op-log state. Fish-side completions for `jj` are unrelated and already work OOTB (nixpkgs jujutsu ships `share/fish/vendor_completions.d/jj.fish` which the home-manager profile auto-links).
- **Why:** Visibility into jj state in the prompt — current change-id (short), description, bookmark, conflict marker — without needing `jj log` every time. Especially useful in colocated repos where git's view and jj's view diverge.
- **How to apply:** Add a `settings` block under `programs.starship` in `home-mac.nix` (and mirror to `home.nix` for upstreaming):
  ```nix
  starship = {
    enable = true;
    settings = {
      format = "$all"; # keep default for now
      jujutsu_change.disabled = false;
      jujutsu_commit.disabled = false;
      jujutsu_bookmarks.disabled = false;
      jujutsu_state.disabled = false;
      # Optional: jujutsu_description.disabled = false;
    };
  };
  ```
  Then re-run `home-manager switch` and open a jj repo to see the modules appear. If the modules don't show up after enabling, override `format` to explicitly include `$jujutsu_change$jujutsu_bookmarks$jujutsu_state` adjacent to `$git_branch$git_status` — `$all` only auto-includes modules that are part of starship's "default group," and the jujutsu modules may not be in it (verify against the locally-pinned starship docs). Decide on placement (next to git? before directory?) to taste.

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

### Mac

For long-form / speculative items (tiling WM choice, status bar stack), see `.claude/todos/mac.md`. Short inline items below.

#### Verify recent Tmux changes still work on Mac

- **Status:** Not started. A run of Linux-side tmux iteration (commits roughly 089716b..HEAD) reshaped `tmux.conf`; needs a Mac sweep.
- **Why:** Mac and Linux run the same `tmux.conf` but differ on tmux build (Homebrew vs. nixpkgs), terminal (Kitty here), and version string formatting. Anything keyed on version detection, terminal capabilities, or the fish+starship stack can quietly drift.
- **How to apply:** Reload on Mac (`tmux source-file ~/.config/tmux/tmux.conf` from inside tmux, or restart tmux) and walk these spot-checks:
  - `prefix + ]` copies the last command's output (commit `58776fa`).
  - Shift+Enter under Kitty inserts a newline in Claude Code's prompt instead of submitting (commit `661d4f0`).
  - `prefix + o` / `prefix + i` cleanly use the `❯`-search fallback under fish+starship (commit `603df25`); the OSC-133 branch is intentionally skipped — see the OSC-133 TODO above for the re-enable plan.
  - Tmux version arithmetic (`%if $IS_TMUX_3_4_OR_ABOVE`) resolves correctly on Mac's tmux build (commit `9b3202d`); if it resolves the wrong way you'll see the wrong navigation branch.
  - `tmux-resurrect` / `tmux-continuum` save+restore round-trips cleanly after the session-0 hook removal (commit `41427ab`).

#### Verify recent Nvim changes still work on Mac

- **Status:** Not started.
- **Why:** Several `vimrc.org` edits were motivated by Linux-specific issues (non-NixOS `libstdc++` dlopen, deprecation warnings on a specific plugin version) but landed in the shared file. Mac needs a sanity pass.
- **How to apply:** Open nvim on Mac after a re-tangle + `home-manager switch` and verify:
  - No which-key deprecation warning at startup (commit `9bd85f7`).
  - Treesitter loads cleanly with no errors mentioning `norg` (commit `dcf82c6`) or `ipkg` (commit `0d69bc1`).
  - `*.jjdescription` files get diff-style highlighting — open one via `jj describe` to confirm (commit `70b3e89`).
  - LSP, completion (nvim-compe), and treesitter highlighting still work end-to-end (regression check; the migration TODO is separately tracked above).

#### Verify recent Fish / home-manager changes still work on Mac

- **Status:** Not started.
- **Why:** `home.nix` reshuffles (alphabetize deps, silence the news notice, Ubuntu-leaning improvements) could nudge something Mac-relevant; want a clean `home-manager switch` and a sane fish session.
- **How to apply:**
  - Run `home-manager switch` on Mac; expect no new warnings beyond the usual (commits `036b128`, `b86bf5e`, `089746b`).
  - Open a fresh fish session and confirm: starship prompt renders, aliases work, jujutsu shell integration is active.
  - Cross-check `home.nix` for anything Linux-only that leaked into the shared file via `089746b` — should be either Mac-safe or platform-gated.

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

#### Up next, once the verify-Linux-on-Mac items above are resolved

Revisit the **Mac tiling window manager** decision in `.claude/todos/mac.md` (SIP question → yabai vs. AeroSpace vs. Amethyst → SketchyBar stack). Surface the prompt then; don't act before the verify sweep is done, since a tiling WM swap will itself disturb tmux/Kitty interactions and we want a stable baseline first.

## Related repo conventions

- Per-app config dirs (`alacritty.yml`, `kitty.conf`, `i3.config`, `espanso/`, `mpv/`, `awesome/`, `openmw/`, `BAR/`, etc.) are wired up via home-manager — check the relevant `home*.nix` to see how a given file lands in `$HOME`.

### Local skills

Reusable Claude Code interaction skills live under `.claude/skills/` in this repo and are symlinked into `$HOME/.claude/skills/` via home-manager (look for the matching `home.file` entry in each `home-*.nix`). They are available to every Claude Code session regardless of working directory.

- **`didactic-upstream-diff-iteration`** (`.claude/skills/didactic-upstream-diff-iteration/SKILL.md`) — one-at-a-time review pattern for upstream-config audits and similar batched-change tasks. Per-candidate Adopt / Decline / Skip prompts, confirm-or-back-out on adopt, persistent rejection list so declined items don't re-surface. Used by `.claude/agents/tmux-upstream-audit/agent-prompt.md`.
