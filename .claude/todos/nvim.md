# Neovim modernization project

The user's `vimrc.org` has had only incremental tweaks for ~4 years. The plugin ecosystem has moved substantially in that time — native LSP matured, Lua-first config became the norm, the completion-engine generation rolled over, file-explorer paradigms diversified, and several new productivity primitives (movement, marks, AI completion, modern git/jj UIs) emerged. This file is the canonical project tracker for catching the config up.

Voice: dense `.claude/` style. Optimized for AI re-reads, not human scan time.

## Values guiding decisions

Mirror the Sway project's value ordering exactly:

1. **Low ongoing maintenance** — like ripgrep / fish: works out of the box, minimal config to keep working.
2. **Maturity / stability** — immature tools only if they exceptionally meet other criteria.
3. **Aesthetics** — daily-driver editor, looks matter.
4. **Low migration churn** — pick things we won't have to re-pick in another 12 months.

Tier semantics used below:
- 🟢 must-do (load-bearing; everything else depends on this)
- 🔵 high value (deep daily improvement)
- 🟡 worth considering (real upgrade, can be evaluated standalone)
- ⚪ marginal (current works fine; upgrade is taste-driven)
- ⚫ skip-for-now (out of scope; revisit only if pain emerges)

## Project shape

Phase split decided 2026-05-24:

- **Phase 1 — deep initial refactor** (everything is coupled; do as one bundle, one commit per logical step inside it):
  - LSP wiring (nvim-lspconfig setup calls + mason-lspconfig auto-install)
  - Completion engine swap (nvim-compe → nvim-cmp)
  - Treesitter migration to `main` branch + new API
  - Snippets engine (LuaSnip — required by nvim-cmp)
  - AI tab completion via minuet-ai.nvim (Anthropic provider)
  - Jujutsu integration module (`lua/zyst/jj.lua` with `:JJFiles`)
- **Phase 2 — incremental modernizations** (each walked through with the `didactic-upstream-diff-iteration` skill, one category at a time, adopt/decline/test/commit):
  - File explorer (NERDTree → oil.nvim and/or nvim-tree.lua)
  - Status line (vim-airline → lualine.nvim)
  - Fuzzy finder (fzf+fzf.vim → Telescope, OR keep fzf and audit)
  - Linter / formatter (ALE → split into LSP + conform.nvim + nvim-lint, OR keep ALE)
  - AI tab completion (minuet-ai.nvim with Anthropic provider — new category)
  - Jujutsu integration (roll-our-own `:JJFiles` command — new category)
  - Diagnostic UI (trouble.nvim — new category)
  - Movement (flash.nvim or leap.nvim — new category)
  - Marks/quick-nav (harpoon.nvim — new category)
  - Folding (nvim-ufo — new category)
  - Indent guides (indent-blankline.nvim — new category)
  - Better git diff (diffview.nvim — new category)
  - Theme refresh (Kanagawa / Rose Pine — user expressed interest)
  - Marginal upgrades: vim-surround→mini.surround, vim-commentary→Comment.nvim/builtin, auto-pairs→nvim-autopairs (queue last)

## Decisions made in this session (2026-05-24)

- **Plugin manager:** stay on **vim-plug**. Initial recommendation was lazy.nvim ("we're refactoring anyway, amortize the cost"), but on pushback that's sunk-cost framing. User has no complaint with vim-plug and explicitly noted startup speed isn't a pain point — which eliminates lazy.nvim's load-bearing benefit. vim-plug is more likely to "outlast" in raw-existence terms (10+ years old, single-file vimscript, near-zero surface area for breakage, still actively maintained by junegunn). Real friction with vim-plug today: occasional copy-paste from docs that ship lazy.nvim spec format (mechanical conversion). Revisit only if (a) vim-plug stops being maintained, or (b) a wanted plugin effectively requires lazy.nvim.
- **AI completion approach:** tab-completion via the Anthropic API (NOT agentic plugins like avante.nvim). Plugin candidate: **minuet-ai.nvim** — provider-agnostic, supports Anthropic, easy provider-swap later. Honest caveat: Claude's API isn't latency-optimized like Copilot/Supermaven, so ghost-text will feel slower. If latency annoys after a week of use, swap the provider config (same plugin) to Supermaven or similar. Cost is per-token on a separate Anthropic API key (Claude Code subscription does not include API access).
- **Shell-out commands (wincent's `shellbot.lua` pattern, e.g. `:Claude` on visual selection):** SKIP for now. User's existing tmux + Claude Code flow already covers the "consult Claude about this code" use case. Add later only if the copy-paste-to-tmux pattern becomes annoying enough to justify a plugin.
- **Jujutsu integration:** roll-our-own. No mature jj nvim plugin exists today (the few that do are single-maintainer / sparsely-documented and don't meet our stability bar). The user's must-have is a `:GFiles?` equivalent for jj-tracked changes. ~25 lines of Lua wrapping `jj diff --name-only` piped to a picker. Slot in a `lua/zyst/jj.lua` module. More commands (`:JJLog`, `:JJBlame`-from-buffer-line) added only if/when the workflow calls for them — nice-to-have, not blockers.
- **Themes of interest (for the Phase 2 theme step):** Kanagawa (Hokusai-inspired, muted blues/golds; variants: wave/dragon/lotus) and Rose Pine (soft mauves/pinks; variants: main/moon/dawn). User explicitly liked both. Current `everforest` may stay; pick happens in Phase 2.
- **Process:** Phase 1 is a coupled bundle, done in this big session (or 2-3 sessions if it sprawls). Phase 2 uses the **`didactic-upstream-diff-iteration` skill** to walk each category — pitch candidates, adopt/decline/skip per category, test, commit, log decision back here.

## Per-category candidate inventory

Full inventory below. Already-decided picks marked. Phase 2 categories carry candidate lists for later iteration.

### Upgrades to existing tools

| Category | Current state | Modern options | Tier | Phase |
|---|---|---|---|---|
| LSP wiring | Plumbing half-installed: `nvim-lspconfig` + `mason.nvim` present, `mason.setup()` ~ vimrc.org:1043, but no `lspconfig.<server>.setup{}` calls and Mason's package dir doesn't exist. **Zero clients attach.** | (a) **Add mason-lspconfig as bridge with `ensure_installed = {...}`** (most ergonomic); (b) skip Mason entirely, install LSP servers via apt/brew (wincent-style — simpler but per-machine imperative). Server baseline: lua_ls, ts_ls, pyright, gopls, rust_analyzer, nixd, clojure_lsp. Narrow to languages actually in daily use. | 🟢 | 1 |
| Completion engine | **✅ Done 2026-05-25**. Switched from `nvim-compe` to **nvim-cmp** with LuaSnip as the snippet engine. Setup lifted heavily from wincent's `nvim-cmp.lua` — sources (luasnip, nvim_lsp, nvim_lua, buffer, calc, emoji, path), `formatting.format` with LSP-kind icons + source-name labels, bordered completion + documentation windows. Tab/Shift-Tab navigate, `<CR>` confirms only an actively-selected entry (`select = false`), `<C-Space>` dropped because tmux's prefix swallows it. LuaSnip moved to its own subsection in `vimrc.org` so future snippet-engine swaps are surgical. `float-preview.nvim` retired (cmp's bordered docs window subsumes it). Six sources register at startup; `nvim_lsp` registers when LSP clients attach (gated by step 3 below). | — | 🟢 | 1 |
| Treesitter API | **✅ Done 2026-05-25** (commit `5c9fd08a`). Migrated to `main` branch + new API. Parsers auto-install at startup via `require('nvim-treesitter').install({...})`; FileType autocmd calls `vim.treesitter.start()` to enable highlighting. nvim-compe `treesitter` source temporarily disabled — proper fix lands with the cmp migration (step 2 below). Required `pkgs.tree-sitter` in common.nix because the main branch compiles parsers from source. | — | 🟢 | 1 |
| Linter / formatter | ALE — monolithic (LSP + lint + format in one). Works, but split-responsibility is cleaner with native LSP. | (a) Keep ALE (it works); (b) split: LSP handles diagnostics, **conform.nvim** for formatters, **nvim-lint** for non-LSP linters. | 🟡 | 2 |
| Status line | vim-airline (Vimscript, slower, older). | (a) **lualine.nvim** (Lua, fast, themable, most popular); (b) hand-rolled in Lua à la wincent. | 🔵 | 2 |
| File explorer | NERDTree. | (a) **oil.nvim** (edit directory as a buffer — paradigm shift, very popular); (b) **nvim-tree.lua** (drop-in NERDTree replacement); (c) **neo-tree.nvim** (more featureful, more knobs). Wincent runs nvim-tree + oil simultaneously. | 🔵 | 2 |
| Fuzzy finder | fzf + fzf.vim + fzf-lsp.nvim. Used heavily; fast on large repos. | (a) Keep fzf (mature, faster than Telescope on huge codebases); (b) **Telescope** (Lua, deeper LSP/treesitter integration, themable but slower); (c) **fzf-lua** (Telescope's API ergonomics with fzf's speed). | 🟡 | 2 |
| Plugin manager | vim-plug. | **Stay on vim-plug** — DECIDED 2026-05-24, see Decisions section above. lazy.nvim was initially recommended and reversed after honest reassessment. | ⚫ | n/a |
| Surround | vim-surround (tpope, vimscript, works). | (a) **mini.surround** (wincent uses; part of mini family); (b) **nvim-surround** (standalone Lua). Marginal. | ⚪ | 2 |
| Comment | vim-commentary (tpope, vimscript, works). | (a) **Comment.nvim**; (b) nvim's **builtin commentary** (since 0.10 via `gc`). Marginal — builtin makes the plugin redundant. | ⚪ | 2 |
| Auto-pairs | jiangmiao/auto-pairs. | **nvim-autopairs** (better LSP integration; closes brackets with awareness of completion context). Marginal. | ⚪ | 2 |
| Polyglot syntax | vim-polyglot (bulk-import of language packs). | Largely obsoleted by treesitter highlighting. Drop after treesitter migration lands. | ⚪ | auto-resolved by Phase 1 |

### Greenfield (no existing tool)

| Category | Why want it | Candidates | Tier | Phase |
|---|---|---|---|---|
| AI tab completion | Explicit ask. Faster boilerplate, in-line ghost-text suggestions. | **minuet-ai.nvim** (Anthropic provider) — DECIDED 2026-05-24. Alternatives noted: Supermaven, Copilot.lua, Codeium — for fallback if Claude latency annoys. | 🔵 | 1 (introduce early in modernization; refine in Phase 2 if needed) |
| Jujutsu integration | Equivalent of `:GFiles?` for jj-tracked changes. fugitive doesn't speak jj. | **Roll our own** — DECIDED 2026-05-24. ~25 lines of Lua wrapping `jj diff --name-only` piped to fzf/Telescope. Future commands queued nice-to-have. | 🔵 | 1 (small enough to land with Phase 1) |
| Snippets engine | nvim-cmp depends on one; also useful standalone. | **LuaSnip** — DECIDED 2026-05-24 (de-facto standard, wincent uses, tightly integrated with nvim-cmp via `cmp_luasnip`). | 🟢 | 1 |
| Diagnostic UI | LSP without a diagnostics panel is half the experience. | **trouble.nvim** (Folke, polished, popular). | 🔵 | 2 |
| Movement / jumps | 2-char prefix jump anywhere on screen. Productivity unlock. | (a) **flash.nvim** (Folke, newer, more featureful — also does treesitter selection); (b) **leap.nvim** (older, more minimal). | 🟡 | 2 |
| Marks / quick-nav | Pin 4-5 files for instant Mod-N jump. Many users describe it as workflow-changing. | **harpoon.nvim 2.x** (ThePrimeagen; canonical). | 🟡 | 2 |
| Folding | Smarter folds via LSP/treesitter. | **nvim-ufo**. | 🟡 | 2 |
| Indent guides | Visual hierarchy. | **indent-blankline.nvim** (wincent uses). | 🟡 | 2 |
| Better git diff | Side-by-side diff inside nvim. | **diffview.nvim** (wincent uses; pairs with fugitive). | 🟡 | 2 |
| Theme refresh | Aesthetic; current `everforest` is fine but 4y old. | **Kanagawa** / **Rose Pine** noted as user-interesting. Also: catppuccin, tokyonight, kanagawa, gruvbox-material. | ⚪ | 2 |
| Notifications / cmdline overhaul | Replace cmdline + search + messages with floating UI. | **noice.nvim** (very aesthetic, more moving parts); **fidget.nvim** (just LSP progress, minimal). | ⚪ | 2 |
| Outline / structure | Symbol tree of current file. | **aerial.nvim**. | ⚪ | 2 |
| Shell-out commands (`:Claude`-style) | Send buffer/selection to Claude CLI from nvim. | Wincent's **shellbot** pattern. SKIP for now per 2026-05-24 decision — covered by user's tmux+claude flow. | ⚫ | n/a |
| Bufferline (VSCode-style tabs) | Buffer tabs at top of screen. | **bufferline.nvim**. SKIP — not the user's workflow. | ⚫ | n/a |
| Dashboard / startup screen | Pretty startup view. | **alpha-nvim**. SKIP — boilerplate. | ⚫ | n/a |

## Reference: wincent's nvim stack (`~/dev/wincent/aspects/nvim/`)

Wincent (a serious vim/nvim user with similar values) currently runs:

- **Plugin manager:** native nvim packpath (`pack/bundle/opt/`) with vendored plugins. No vim-plug, no lazy.nvim, no packer. We're not adopting this — lazy.nvim is more ergonomic for our scale — but it's an interesting minimal-dependency option to know about.
- **Completion:** nvim-cmp + LuaSnip + cmp-{buffer,calc,emoji,luasnip,nvim-lsp,nvim-lua,path} sources. This is essentially our Phase-1 target.
- **LSP:** nvim-lspconfig with hand-written per-server setup. **No Mason** — he installs language servers via OS package manager (apt / brew / aur). Cleaner but per-machine imperative.
- **File mgmt:** **oil.nvim + nvim-tree.lua simultaneously** — oil for buffer-as-directory navigation, nvim-tree for the sidebar. Worth knowing the dual-tool pattern exists.
- **Text-object / surround:** mini.surround + mini.ai (replaces vim-surround). His `after/plugin/mini.ai.lua` and `mini.surround.lua` are short and worth borrowing.
- **Git:** vim-fugitive + diffview.nvim + vim-rhubarb (GitHub) + vim-git. Phase-2 reference for our git stack upgrade.
- **AI:** `shellbot.lua` exposes `:Claude`, `:Opus`, `:Sonnet`, `:ChatGPT` commands that shell out to the respective CLIs. **Same philosophy as our user's "no agentic plugins, prefer Claude CLI in tmux".** We're skipping this for now, but the pattern is a known-good fallback if our tmux+claude flow ever feels insufficient.
- **Status/tabline:** hand-rolled in Lua (`plugin/statusline.lua`, `plugin/tabline.lua`).
- **Indent:** indent-blankline.nvim.
- **Movement (folds, search):** zen-mode.nvim, loupe (his own plugin), scalpel (his own).
- **Find/grep:** ferret (his own; vim grep wrapper).

When making picks in Phase 2 and stuck between options, check wincent's `~/dev/wincent/aspects/nvim/files/.config/nvim/after/plugin/<plugin>.lua` for that plugin (if he uses it) — his configs are short, opinionated, and worth borrowing.

## Open questions to resolve as we go

- **AI completion: try minuet-ai.nvim's Anthropic backend immediately, or start with Supermaven/Copilot to establish baseline latency expectation and *then* switch to Claude?** Tradeoff: starting with the "right" model means accepting latency we may not need; starting with a fast competitor means knowing how good ghost-text *can* feel before evaluating Claude.
- **LSP: Mason or no Mason?** Mason auto-installs servers per-machine but adds a layer of indirection. wincent skips Mason entirely. For a multi-machine dotfiles repo, Mason is the more declarative choice. Lean Mason-yes pending counter-argument.
- **Fuzzy finder: keep fzf, swap to Telescope, or land on fzf-lua?** fzf is faster on huge repos and the user's muscle memory is there. Telescope is the Lua-first default. fzf-lua hybrids the two. Defer to Phase 2 with no strong pre-commitment.
- **File explorer: oil-only, nvim-tree-only, or both?** Wincent runs both. They serve different workflows (sidebar vs in-buffer). May converge on both during Phase 2 trial.
- **Lualine vs hand-rolled status line?** Lualine is lower friction; hand-rolled gives full control. The user's current vim-airline is already styled, so swap-to-lualine is the path of least resistance.
- **`programs.neovim` Python3/Ruby providers:** currently `withPython3 = false; withRuby = false;` per CLAUDE.md. If any Phase 2 plugin needs python3 (notably: some snippets, some older completion sources), flip the flag in `common.nix` (or wherever `programs.neovim` now lives post-common.nix-split) and `home-manager switch`.

## Process

For Phase 1: walk it as one big change-stack in a single (or 2-3) session(s). Order:

1. ✅ Migrate nvim-treesitter to `main` API. **Done 2026-05-25, commit `5c9fd08a`.** Side-effects captured for follow-up: nvim-compe `treesitter` source temporarily set to `false` (fixed by step 2 below); `pkgs.tree-sitter` added to common.nix.
2. ✅ Migrate nvim-compe → nvim-cmp + LuaSnip + cmp-* sources. **Done 2026-05-25.** Sources, mappings, bordered windows, and LSP-kind icons all in place; cmp-treesitter intentionally not added (skipped per scope discussion — re-add later if we miss it). LuaSnip lives in its own `vimrc.org` subsection for clean future swaps. `float-preview.nvim` retired alongside compe.
3. Wire up LSP properly — pick baseline servers, add mason-lspconfig with `ensure_installed`, write the setup-handlers loop. Re-tangle, switch, verify `:checkhealth vim.lsp` shows attached clients. This is also what brings the `[LSP]` source online for cmp. Commit.
4. Add minuet-ai.nvim with Anthropic provider. Configure API key via the secrets-management approach in use. Test ghost-text. Commit.
5. Add the `lua/zyst/jj.lua` module with `:JJFiles` command, wire keybinding. Commit.

For Phase 2: use the `didactic-upstream-diff-iteration` skill. Each category becomes one didactic-iteration session. Decisions logged back into this file's "Decisions" section as they land.

## Resumption / Where we left off (2026-05-25)

- **Phase 1 steps 1 and 2 done.** Treesitter (commit `5c9fd08a`) and nvim-compe → nvim-cmp + LuaSnip migration both landed. Interactive validation passed: clean nvim startup, `[Buf]` / `[Path]` / `[Snip]` / `[Calc]` / `[Lua]` / `[Emoji]` source labels showing, Nerd Font kind glyphs rendering via Kitty's bundled fallback, Tab/Shift-Tab navigation behaving as expected.
- **Phase 1 step 3 is next**: wire up LSP via `nvim-lspconfig` + `mason-lspconfig` (auto-install bridge) with `ensure_installed = {...}` for the baseline server list (lua_ls, ts_ls, pyright, gopls, rust_analyzer, nixd, clojure_lsp — narrow to what's actually in daily use). The setup-handlers loop wires servers into cmp via `require('cmp_nvim_lsp').default_capabilities()`. Activating this also lights up the `[LSP]` source in cmp (currently the only source from our config that doesn't register at startup — gated on a client attaching).
- Steps 4–5 (minuet-ai → jj module) remain queued in order.
- The existing TODOs in `.claude/todos/todos.md` (nvim-cmp/treesitter migration; LSP wiring) are now subsumed by Phase 1 here. Those entries should be replaced with one-line pointers to this file (deferred to whoever picks this up next, to keep this file's introduction self-contained).
- **Resumption prompt — Claude should open the next session with this question, verbatim:**
  > Ready to continue Phase 1? Step 3 (LSP wiring via nvim-lspconfig + mason-lspconfig) is queued next; steps 4–5 (minuet-ai, jj module) follow. Recommend continuing in one session if you can; otherwise we can checkpoint between steps.
