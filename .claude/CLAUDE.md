# Dotfiles — Claude project context

This file is the portable, machine-independent source of truth for how Claude should work on this repo. Memory under `~/.claude/projects/-Users-zyst/memory/` is per-machine and won't follow this repo to a new laptop — this file does. When setting up a new machine, this is the bootstrap context.

## Sync rule

Whenever a dotfile-related fact is added/updated/removed in user memory (`~/.claude/projects/-Users-zyst/memory/`), mirror the change here in the same edit. The two should not drift. Sections below map roughly 1:1 to memory files; keep the mapping legible.

The reverse also applies: if you update this file with a new dotfiles fact and no memory entry exists yet, add one under `~/.claude/projects/-Users-zyst/memory/` and link it in `MEMORY.md`.

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
   cd ~/dev/dotfiles && emacs --batch --eval "(progn (require 'org) (find-file \"vimrc.org\") (org-babel-tangle))"
   ```
3. `home-manager switch` to publish the new `.vimrc` into the Nix store and update the `~/.vimrc` symlink.

### Special case — vim-plug plugin branch/version changes

vim-plug does **not** auto-switch the branch of an already-checked-out plugin when you change the `Plug` line. After steps 1–3 above, also:

```
rm -rf ~/.config/nvim/plugged/<plugin>
nvim --headless '+PlugInstall --sync' '+qa'    # run from a valid cwd like ~
```

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

### Migrate `nvim-compe` → `nvim-cmp`, and `nvim-treesitter` to the new `main` API

- **Status (as of 2026-05-13):** `nvim-treesitter` is pinned to its legacy `master` branch in `~/dev/dotfiles/vimrc.org:888` so the old `require'nvim-treesitter.configs'.setup{}` API still works and `nvim-compe`'s internal `compe_treesitter` source still loads. `nvim-compe` is archived/deprecated by its author in favor of `hrsh7th/nvim-cmp`.
- **Why it matters:** Eventually the `master` branch of `nvim-treesitter` will bitrot and the workaround stops working.
- **How to apply:** Two coupled changes in `vimrc.org`:
  1. Replace the `Plug 'hrsh7th/nvim-compe'` block and `require'compe'.setup{…}` config with `nvim-cmp` + sources (`cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, etc.) and a snippet engine like `LuaSnip`.
  2. Drop the legacy `master` pin on `nvim-treesitter` and migrate the `setup{}` call to the new API — `:TSInstall <langs>` (no more `ensure_installed = "all"` in setup) plus a `FileType` autocmd calling `vim.treesitter.start()`.

  Then: re-tangle → `home-manager switch` → `rm -rf` the affected plugin dirs → `:PlugInstall`. See the vim-plug branch-change note above.

## Related repo conventions

- `makesymlinks.sh` / `makesymlinks.js` predate the home-manager workflow; home-manager is the canonical mechanism now.
- Per-app config dirs (`alacritty.yml`, `kitty.conf`, `i3.config`, `espanso/`, `mpv/`, `awesome/`, `openmw/`, `BAR/`, etc.) are wired up via home-manager — check the relevant `home*.nix` to see how a given file lands in `$HOME`.
