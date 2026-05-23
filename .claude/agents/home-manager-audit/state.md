# home-manager audit iteration state — 2026-05-23

Tracks adopt/decline decisions on findings from `report-2026-05-23.md` so the didactic walk doesn't re-surface already-decided items.

## Pending

- L4 — Consider `programs.fzf.tmux.enableShellIntegration` for popup integration
- L5 — Investigate whether `.config/environment.d/10-shell.conf` (Linux) is still needed

Structural (separate decision):
- Cross-file parity → factor a shared `common.nix`

## Adopted

- **M4 — `programs.neovim`** (adopted 2026-05-23, both files). `pkgs.neovim` + `pkgs.neovim-node-client` replaced by `programs.neovim = { enable = true; withNodeJs = true; withPython3 = false; withRuby = false; extraConfig = …; }`. The `withPython3`/`withRuby = false` decision was explicit (matches pre-M4 provider surface; legacy default would have wrapped both in). A note about flipping them back to `true` if a plugin needs python3/ruby providers lives in `.claude/CLAUDE.md` § Special case — Nvim plugins requiring python3 / ruby providers. The bootstrap `init.vim` content was absorbed into `extraConfig`; module writes `~/.config/nvim/init.lua` (modern API) which sources the extraConfig vimscript blob from the nix store. The `~/.vimrc` symlink stays (vimrc tangling out of audit scope). Verified: new wrapper PATH-prepends only nodejs; `vim.g.node_host_prog` set, python3/ruby providers explicitly disabled.

- **H2 — `programs.gh` + credential helper management** (adopted 2026-05-23, both files). Mac verified end-to-end: gh binary still on PATH, `co` alias preserved (captured into `programs.gh.settings.aliases.co`), gh auth status untouched (SSH protocol, keyring intact), global credential.helper trimmed to `[osxkeychain]`/`[libsecret]`, scoped `credential.https://github.com.helper` + `credential.https://gist.github.com.helper` auto-emitted by the module pointing at an absolute nix-store path. Pre-existing `~/.config/gh/config.yml` saved to `.pre-gh-module` as backup.

## Declined

- **H1 — `programs.bat`** (declined 2026-05-23). Config is a single `--theme="base16"` line; the raw `home.file` form is closer to what you'd write by hand on a non-Nix machine, and the typed-attrset / type-checking wins of `programs.bat.config` don't justify the change at this size. Reconsider only if bat config grows past one or two non-string options. **Heuristic for similar findings in this audit:** for small `programs.X.enable`-only swaps with no other behavioral change, the explicit `pkgs.X` in `home.packages` reads more transparently to a future-self bootstrapping on a non-Nix machine. Apply the same lens to M1 (htop), M2 (jq), M6 (fastfetch), M7 (yt-dlp) — same shape, same decline reasoning likely applies unless I'm overlooking a benefit.

- **M1 — `programs.htop`** (declined 2026-05-23). htop used only casually; current bare-package install fine. Reconsider only if/when the user starts declaring `~/.config/htop/htoprc` from Nix.

- **M2 — `programs.jq`** (declined 2026-05-23). User tested default jq colors against a mixed-type JSON object and was satisfied. Module's only knob (`colors`) doesn't offer anything wanted.

- **L3 — Remove redundant `programs.fzf.enableFishIntegration`** (declined 2026-05-23). User prefers keeping the explicit `enableFishIntegration = true` as documentation — defends against silent regression if home-manager ever flips the default in a future release. Symmetric counter-argument to the "explicit on non-Nix" pattern: here, "explicit on default-changes" reads more conservatively.

- **M8 — `programs.ranger.enable`** (declined 2026-05-23 after empirical test). Tested adoption; `home-manager switch` failed at evaluation time with `error: Conflicting managed target files: .config/ranger/rc.conf` — the module always emits its own rc.conf, even with only `enable = true` set. Same shape as the gh config.yml clash but caught earlier. Adopting would require absorbing the user's rc.conf into typed `programs.ranger.{settings, aliases, mappings, rifle, plugins}` options (explicitly deferred per the audit's Check 5 scope rule). Reconsider only if the user decides to absorb rc.conf into Nix later.

- **M7 — `programs.yt-dlp`** (declined 2026-05-23). No `~/.config/yt-dlp/` today, no behavior change from `enable`-only. Same H1/M1/M2/M6 shape.

- **M6 — `programs.fastfetch`** (declined 2026-05-23). Running on defaults, no `~/.config/fastfetch/` today. Same H1/M1/M2 shape — no behavior change, "explicit on non-Nix" preference applies.

- **M5 — `programs.tmux` skeleton** (declined 2026-05-23). User runs `tmux.conf` across many environments without Nix (servers, ssh hosts, etc.); the module's preamble + the `~/.tmux.conf` → `~/.config/tmux/tmux.conf` path move would create divergence from the portable single-file config. The declarative-plugins win is real but not worth losing portability. Reconsider only if the user decides to drop multi-environment portability for tmux (unlikely).

- **M3 — `programs.ripgrep`** (declined 2026-05-23). User has no `~/.config/ripgrep/` or `~/.ripgreprc` today and no specific flag they've been wanting rg to default to. The `arguments` typed list is the only thing the module adds beyond a bare package install; with `arguments = []` it's a no-op (M1/M2 shape), with arguments set it'd be a guess. Reconsider only if the user develops a clear "I always wish `rg` defaulted to X" itch.

- **H3 — `programs.eza`** (declined 2026-05-23). User has a custom `alias ls="eza --tree --level=1"` in config.fish that they want to keep authoritative. Module's `enableFishIntegration = true` (default) would emit a competing `ls` alias (overridden by the user's config.fish because of file-load ordering, so no functional regression), but the only thing the module-with-fish-integration buys is sensible `ll`/`la` aliases — which the user can opt into manually if/when desired. Other module knobs (`git = true` for status indicators, `icons`, `theme`) are reachable by adding flags to the existing alias, so they're not module-exclusive. Tab completion already works via the bare-package's `share/fish/vendor_completions.d/eza.fish`. Same H1 decline pattern applies.

## No-op confirmations (no action needed — read-only audit findings)

- L1 — `programs.starship.enableFishIntegration` default true; config is correct
- L2 — `programs.jujutsu.enableFishIntegration` hidden/auto; correctly not set
- L6 — Various `pkgs.*` correctly stay in `home.packages` (no module exists)
- L7 — `programs.man.enable` + `extraOutputsToInstall = [ "man" ]` pair is correct
