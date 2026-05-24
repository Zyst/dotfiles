# Generic dotfile TODOs

Non-platform-specific repo-wide items affecting shared config (vimrc.org, tmux.conf, home-manager idioms, etc.). See sibling files for platform-scoped TODOs:

- `linux.md` — Linux-specific
- `mac.md` — macOS-specific

Memory's `~/.claude/projects/-Users-zyst/memory/todos.md` mirrors items per the sync rule in CLAUDE.md, but **this file is the canonical, in-repo source** — it survives an OS hop, while memory is per-machine.

When picking an item, walk it didactically (one change at a time, adopt/decline, test, commit). Done items get deleted from this file outright — see the `feedback_todo_deletion.md` memory entry for the rule.

---

## Audit upstream wincent `tmux.conf` for new / polished patterns via didactic-upstream-diff-iteration

- **Status:** Not started. Audit prompt lives at the repo-relative path `.claude/agents/tmux-upstream-audit/agent-prompt.md`; rejection state at the sibling `rejected.md`.
- **Why:** `tmux.conf` is heavily lifted from `wincent/wincent` (see CLAUDE.md "tmux.conf upstream reference"), and there are known unadopted patterns — but new bindings compete with muscle memory, so each candidate needs to be tested individually before it stays. The audit drives the `didactic-upstream-diff-iteration` skill over a seeded candidate list (one-at-a-time review, no bulk import).
- **How to apply:** Open the agent prompt at `.claude/agents/tmux-upstream-audit/agent-prompt.md` and ask Claude to follow it. The first instruction in that prompt is to load the `didactic-upstream-diff-iteration` skill (symlinked into `$HOME/.claude/skills/` via home-manager); the skill then walks the seeded "Pending candidates" section one entry at a time. Declines land in `./rejected.md` so they don't re-surface on later runs.

---

## Vendor `wincent/wincent` as an upstream subrepo + add an auto-sync skill

- **Status:** Not started. We currently reference wincent's configs by raw GitHub URL on each audit. A local checkout exists informally at `/Users/zyst/dev/wincent/` on the Mac (cloned 2026-05-24 mid-session); formal vendoring into the dotfiles repo is still queued.
- **Why:** A repo-local checkout (e.g. under `upstream/wincent/`) would let `rg`, `git log`, and the existing audit tooling work against it for fast diffs, make the upstream readable offline, and let us pin to a known commit and bump deliberately instead of racing whatever `main` is on each `WebFetch`. A companion **sync skill** keeps the checkout fresh on demand so it doesn't go stale silently.

  **Important caveat to encode once vendored — authority vs. staleness:** treat wincent's repo as an authoritative source *only for tools wincent still actively uses.* If he has moved off a tool (e.g. changed terminals, dropped a plugin, switched window manager), the file we'd be referencing is a fossil — less trustworthy than internal experimentation or current web sources. Before treating any wincent file as canonical, do a recency check on his recent commits / activity for that file; if it hasn't been touched in a long time, or his current configs reference a different replacement, downgrade its authority and prefer internal/web sources.

- **How to apply:**
  1. Pick the vendoring mechanism (submodule is simplest; subtree avoids the `.gitmodules` dance and keeps clones single-step). Vendor `wincent/wincent` under a repo-relative path like `upstream/wincent/`.
  2. Build a new skill (likely `.claude/skills/sync-upstream-wincent/SKILL.md`) that performs an on-demand fetch + fast-forward (or merge), reports what changed since the last sync, and highlights diffs that touched files we mirror locally (`tmux.conf` first; later anything else we borrow from).
  3. Add the authority-vs-staleness rule to `.claude/CLAUDE.md` (probably under the existing "tmux.conf upstream reference" section, generalized): when consulting a vendored upstream file, check the file's recent commit activity first; if it looks abandoned, treat it as a historical reference rather than canonical.
  4. Once vendored, repoint `.claude/agents/tmux-upstream-audit/agent-prompt.md` at the local checkout instead of the GitHub URL — the audit gets faster and works offline.

---

## Migrate `nvim-compe` → `nvim-cmp`, and `nvim-treesitter` to the new `main` API

- **Status (as of 2026-05-13):** `nvim-treesitter` is pinned to its legacy `master` branch in `~/dev/dotfiles/vimrc.org:888` so the old `require'nvim-treesitter.configs'.setup{}` API still works and `nvim-compe`'s internal `compe_treesitter` source still loads. `nvim-compe` is archived/deprecated by its author in favor of `hrsh7th/nvim-cmp`.
- **Why it matters:** Eventually the `master` branch of `nvim-treesitter` will bitrot and the workaround stops working.
- **How to apply:** Two coupled changes in `vimrc.org`:
  1. Replace the `Plug 'hrsh7th/nvim-compe'` block and `require'compe'.setup{…}` config with `nvim-cmp` + sources (`cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, etc.) and a snippet engine like `LuaSnip`.
  2. Drop the legacy `master` pin on `nvim-treesitter` and migrate the `setup{}` call to the new API — `:TSInstall <langs>` (no more `ensure_installed = "all"` in setup) plus a `FileType` autocmd calling `vim.treesitter.start()`.

  Then: re-tangle → `home-manager switch` → `rm -rf` the affected plugin dirs → `:PlugInstall`. See the vim-plug branch-change note in CLAUDE.md.

---

## Get tmux-resurrect to reattach Claude Code sessions on restore

- **Status:** Long-term, not actively scheduled. Surfaced 2026-05-23.
- **Why:** `tmux-resurrect` (with `tmux-continuum` driving auto-save every 15min) restores window/pane layout and a small whitelist of processes on `prefix + Ctrl-r`, but Claude Code sessions die with the pane. After a restore you get an empty shell where Claude used to be — context lost, conversation gone. If resurrect could be taught to reattach Claude (probably by re-running `claude` with a flag that resumes the most recent session for that working directory, if one exists), session continuity across crashes / reboots / accidental `tmux kill-server` would be much better.
- **How to apply (when picked up):**
  - Investigate resurrect's `@resurrect-processes` option — it accepts a string list of additional binaries to relaunch on restore (e.g. `~vim ~nvim "~claude->claude --resume-last"` style — verify the exact syntax). It's the standard escape hatch for non-default process restoration.
  - Check whether Claude Code has a CLI flag that resumes the latest session for the cwd. If yes, the resurrect process entry can invoke that flag directly. If no, that's a separate ask of the Claude Code team (or work around by recording the session ID into a sidecar file the resurrect hook can read).
  - Decide policy: always reattach (might be jarring if the prior conversation is stale), or reattach only when continuum-restore fires within N minutes of save (continuum saves a timestamp; we can gate on freshness).
  - Sanity-check: does pane content (the visible scrollback) come back via `pane_contents.tar.gz`? If yes, even without true session reattach, the previous transcript is at least visible.
  - Document the final mechanism here once it's wired up so the next reader doesn't have to re-derive it.

---

## Wire up nvim LSP properly (Mason install + nvim-lspconfig setup calls)

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

---

## Re-enable OSC-133 prompt navigation for tmux prefix+o / +i / +]

- **Status (investigated 2026-05-23, deferred):** The OSC-133 branch of `tmux.conf` is gated behind `%if $IS_TMUX_3_4_OR_ABOVE`, and `TMUX_VERSION` is built using wincent's stock `#{s|next-||:#{version}}` regex which does NOT strip trailing letter suffixes. On Ubuntu/nixpkgs the version is `3.6a`, so the arithmetic returns 0 and the `%else` branch (`❯`-search fallback) runs. This is **intentional** — the OSC-133 path doesn't navigate correctly under fish+starship right now.
- **Why deferred:** Fish 4.x has an open regression where OSC-133 `;A` (prompt-start) markers are misplaced on multi-line prompts ([fish-shell#10776](https://github.com/fish-shell/fish-shell/issues/10776)). Starship's default prompt IS multi-line, so plain `previous-prompt` / `next-prompt` skip prompts. Tried workaround: `previous-prompt -o` / `next-prompt -o` (navigate by `;C` output markers) — `-o` works backward but `next-prompt -o` doesn't navigate forward even with content available. The `❯`-search fallback works reliably on both Mac and Linux.
- **What we confirmed during the investigation:** tmux 3.4+ DOES capture OSC-133 marks correctly (verified with `/usr/bin/printf '\033]133;A\033\\'` — manual emission navigates fine). Fish 4.7.1 has `$fish_features` empty, so OSC-133 emission *should* be on by default. The bug is on fish's emission side, not tmux's capture side.
- **How to re-enable when fish ships the fix:**
  1. Change `tmux.conf` line ~186 from `%hidden TMUX_VERSION="#{s|next-||:#{version}}"` to `%hidden TMUX_VERSION="#{s|next-||:#{s|[a-z]+$||:#{version}}}"` (adds the letter-suffix strip).
  2. Verify on Linux+fish+starship that `prefix + o` and `prefix + i` navigate cleanly between multi-line prompts.
  3. The `]` block-copy binding's selection geometry assumes A-markers (cursor lands ON the prompt line); if you experimented with `-o` variants, restore the A-marker logic.
  4. Reference commit `9b3202d` (the abandoned strip attempt) and this conversation's debugging notes for prior art.

---

## Manage Logseq plugin set + per-plugin settings via home-manager (or confirm Logseq Sync covers it natively)

- **Status:** Not started. Surfaced 2026-05-23 as a follow-on to the queued "delete empty Logseq daily journals" cleanup (which introduces the first concrete plugin — `Cologler/logseq-remove-empty-blocks-typescript`, see global `todos.md` at `~/.claude/projects/-Users-zyst/memory/todos.md`).
- **Why:** Logseq plugins are installed per-app, with state in the graph dir (`<graph>/logseq/`) and/or `~/.logseq/` — all outside `~/dev/dotfiles/`. A fresh machine starts with zero plugins and zero settings, which breaks the rest-of-the-repo posture of "rebuild a machine from the dotfiles repo." **Open question first:** Logseq Sync (separate TODO in global `todos.md`) may already sync `<graph>/logseq/`, in which case this TODO collapses to "verify and document." Worth answering before doing any home-manager work.
- **How to apply:**
  1. Test the Sync path first — install a plugin on the Mac, run Logseq Sync, then on a second machine (or in a sandbox graph) confirm whether the plugin auto-installs with its settings preserved.
  2. If Sync covers it: document the finding here and in `~/.claude/projects/-Users-zyst/memory/todos.md`, then close.
  3. If Sync does NOT cover it: identify which Logseq files are canonical plugin config (likely `<graph>/logseq/config.edn` and parts of `<graph>/logseq/plugins/` — distinguish from cached plugin binaries we don't want to vendor) and wire them into `home.nix` via `home.file."…".source = ${dotfiles}/logseq/…;`, matching how other per-app configs are managed. Decide whether plugin binaries themselves are (a) re-downloaded by Logseq on first run from a synced plugin list, (b) vendored in the repo, or (c) Nix-packaged (unlikely for niche community plugins).
  4. Mirror the resolution back to global `todos.md` so both indexes stay in sync.

