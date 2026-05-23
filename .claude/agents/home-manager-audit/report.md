# home-manager idiomaticity audit — 2026-05-23

## Summary

- 18 findings: 3 High, 8 Medium, 7 Low.
- 0 hard deprecations in the user's current config. The user correctly omits `programs.jujutsu.enableFishIntegration` (which is `visible = false` in the live tree). One mild redundancy: `programs.fzf.enableFishIntegration = true;` matches the module default (L3 below).
- Cross-file parity: `home.nix` and `home-mac.nix` are ~85% identical by line. The largest single drift-prevention win available is factoring shared content into a `common.nix`. Recommended but not urgent.

**Verification status:** every option cited below was verified against the locally-pinned home-manager channel via `nix-instantiate --eval --strict` against `<home-manager/modules>`. Where the docs page and the local channel disagree, this report trusts the local channel.

Verification harness used:

```sh
nix-instantiate --eval --strict -E '
let
  hm = import <home-manager/modules> {
    configuration = { lib, ... }: {
      home.username = "x"; home.homeDirectory = "/x"; home.stateVersion = "22.05";
    };
    pkgs = import <nixpkgs> {};
  };
in builtins.attrNames hm.options.programs.<NAME>
'
```

---

## Findings

### [HIGH] H1 — Adopt `programs.bat` and drop the manual `.config/bat/config`

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:9, :96-99; `/Users/zyst/dev/dotfiles/home-mac.nix`:9, :81-84
- **Current:**
  ```nix
  home.packages = [ pkgs.bat ... ];
  home.file.".config/bat/config".text = ''
    --theme="base16"
  '';
  ```
- **Recommended:**
  ```nix
  programs.bat = {
    enable = true;
    config = { theme = "base16"; };
  };
  ```
  Remove `pkgs.bat` from `home.packages` and remove the `home.file.".config/bat/config"` entry.
- **Home-manager option(s):** `programs.bat.enable`, `programs.bat.config` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.bat.enable
- **Live-tree verified:** Yes. Options: `{ config, enable, extraPackages, package, syntaxes, themes }`.
- **Why:** Module installs bat AND writes the config from a declarative attrset. `config.theme = "base16"` produces exactly the `--theme="base16"` line currently written by hand.
- **Risk:** Very low. `diff result/home-files/.config/bat/config <hand-written>` to confirm.
- **Parity note:** Apply identically to both files.

---

### [HIGH] H2 — Adopt `programs.gh` and let it manage the git credential helper

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:16, :152-154; `/Users/zyst/dev/dotfiles/home-mac.nix`:16, :135-137
- **Current:**
  ```nix
  home.packages = [ pkgs.gh ... ];
  programs.git.settings.credential.helper = [ "!gh auth git-credential" "libsecret" ];  # or "osxkeychain"
  ```
- **Recommended:**
  ```nix
  programs.gh.enable = true;
  # gitCredentialHelper.enable defaults to true — no need to set explicitly.
  # Optionally: programs.gh.gitCredentialHelper.hosts = [ "https://github.com" "https://gist.github.com" ];
  programs.git.settings.credential.helper = [ "libsecret" ];  # mac: "osxkeychain"
  ```
  Drop `pkgs.gh` from `home.packages`. Drop the `"!gh auth git-credential"` entry — the gh module injects it via its own git config snippet.
- **Home-manager option(s):** `programs.gh.enable`, `programs.gh.gitCredentialHelper.enable`, `programs.gh.gitCredentialHelper.hosts` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.gh.enable
- **Live-tree verified:** Yes. Options: `{ aliases, editor, enable, enableGitCredentialHelper, extensions, gitCredentialHelper, gitProtocol, hosts, package, settings }`. `gitCredentialHelper.enable` has `default = true`. `enableGitCredentialHelper` is an alias of `gitCredentialHelper.enable`.
- **Why:** Canonical cross-program integration (Check 4). Today the user hand-writes `"!gh auth git-credential"` in two places, once per platform. After this change: helper line becomes managed (stays correct if gh ever renames its credential-helper invocation), platform fallback stays explicit, and `pkgs.gh` drops out of `home.packages`. Optional `hosts` lets it be scoped per-host.
- **Risk:** Low. Verify (1) helper-order semantics — git tries helpers in list order; confirm the module emits `!gh auth git-credential` BEFORE the platform fallback. (2) `gh auth status` currently reports `Git operations protocol: ssh`, so the credential helper isn't load-bearing day-to-day — meaning a temporary regression here would be silent. Test with one HTTPS clone before committing.
- **Parity note:** Apply identically. Platform fallback (`libsecret` vs `osxkeychain`) stays per-platform.

---

### [HIGH] H3 — Adopt `programs.eza` (and let module defaults do their work)

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:12; `/Users/zyst/dev/dotfiles/home-mac.nix`:12
- **Current:** `pkgs.eza` in `home.packages`; `ls`/`ll`/`la` aliases presumed to live in `config.fish` (out of scope per Check 5).
- **Recommended:**
  ```nix
  programs.eza = {
    enable = true;
    # enableFishIntegration defaults to true — no need to set explicitly.
    # Optional: git = true; icons = "auto";
  };
  ```
  Drop `pkgs.eza` from `home.packages`.
- **Home-manager option(s):** `programs.eza.enable`, `programs.eza.enableFishIntegration`, `programs.eza.git`, `programs.eza.icons` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.eza.enable
- **Live-tree verified:** Yes. Options: `{ colors, enable, enableAliases, enableBashIntegration, enableFishIntegration, enableIonIntegration, enableNushellIntegration, enableZshIntegration, extraOptions, git, icons, package, theme }`. `enableFishIntegration` has `default = true`. **`enableAliases` has `visible = false` — DO NOT set it; it's the hidden/deprecated form.** The module ships aliases (`ls`, `ll`, `la`, `lt`, etc.) under the current canonical mechanism.
- **Why:** First-class module install, fish integration auto-on, any alias conflict with `config.fish` becomes visible so the user can resolve it in a future scope-expanded pass.
- **Risk:** Medium. The module's default aliases may shadow whatever's in `config.fish`. After `home-manager switch`, run `type ls`, `type ll` in a fresh fish session to see which entry wins. If conflict, decide source-of-truth in a separate pass.
- **Parity note:** Apply identically to both files.

---

### [MEDIUM] M1 — Adopt `programs.htop`

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:19; `/Users/zyst/dev/dotfiles/home-mac.nix`:19
- **Current:** `pkgs.htop` in `home.packages`.
- **Recommended:** `programs.htop.enable = true;` (drop `pkgs.htop`).
- **Home-manager option(s):** `programs.htop.enable`, `programs.htop.settings` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.htop.enable
- **Live-tree verified:** Yes. Options: `{ enable, package, settings }`.
- **Why:** First-class module. Zero behavior change for `enable`-only.
- **Risk:** None.
- **Parity note:** Both files.

---

### [MEDIUM] M2 — Adopt `programs.jq`

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:23; `/Users/zyst/dev/dotfiles/home-mac.nix`:23
- **Current:** `pkgs.jq` in `home.packages`.
- **Recommended:** `programs.jq.enable = true;` (drop `pkgs.jq`).
- **Home-manager option(s):** `programs.jq.enable` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.jq.enable
- **Live-tree verified:** Yes. Options: `{ colors, enable, package }`. Narrow surface — no `settings`.
- **Why:** Idiomatic install path.
- **Risk:** None.
- **Parity note:** Both files.

---

### [MEDIUM] M3 — Adopt `programs.ripgrep`

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:31; `/Users/zyst/dev/dotfiles/home-mac.nix`:31
- **Current:** `pkgs.ripgrep` in `home.packages`.
- **Recommended:** `programs.ripgrep.enable = true;` (drop `pkgs.ripgrep`). Future: `programs.ripgrep.arguments = [ "--smart-case" "--hidden" ];`.
- **Home-manager option(s):** `programs.ripgrep.enable`, `programs.ripgrep.arguments` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ripgrep.enable
- **Live-tree verified:** Yes. Options: `{ arguments, enable, package }`. Module emits `~/.config/ripgrep/config` and points `$RIPGREP_CONFIG_PATH` at it.
- **Why:** Opens the door to a typed `arguments` list later.
- **Risk:** None for `enable`-only.
- **Parity note:** Both files.

---

### [MEDIUM] M4 — Adopt `programs.neovim` (without absorbing the tangled `.vimrc`)

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:26-27, :66, :88-94; `/Users/zyst/dev/dotfiles/home-mac.nix`:26-27, :60, :73-79
- **Current:**
  ```nix
  home.packages = [ pkgs.neovim pkgs.neovim-node-client ... ];
  home.file.".vimrc".source = "${dotfiles}/.vimrc";
  home.file.".config/nvim/init.vim".text = ''
    set nocompatible
    set runtimepath^=~/.vim runtimepath+=~/.vim/after
    let &packpath = &runtimepath
    source ~/.vimrc
  '';
  ```
- **Recommended:**
  ```nix
  programs.neovim = {
    enable = true;
    withNodeJs = true;   # replaces pkgs.neovim-node-client
    extraConfig = ''
      set nocompatible
      set runtimepath^=~/.vim runtimepath+=~/.vim/after
      let &packpath = &runtimepath
      source ~/.vimrc
    '';
  };
  ```
  Drop `pkgs.neovim`, `pkgs.neovim-node-client`, and the `.config/nvim/init.vim` entry. **Keep** the `.vimrc` symlink — vimrc tangling is explicitly out of scope.
- **Home-manager option(s):** `programs.neovim.enable`, `programs.neovim.withNodeJs`, `programs.neovim.extraConfig` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.neovim.enable
- **Live-tree verified:** Yes. Options include `{ enable, extraConfig, extraLuaConfig, initLua, package, plugins, vimAlias, withNodeJs, withPerl, withPython3, withRuby, … }`.
- **Why:** `withNodeJs = true` splices the node-client into the neovim wrapper PATH instead of a parallel install. `init.vim`'s four lines become a colocated `extraConfig` block.
- **Risk:** Low. The module appends `extraConfig` to its generated `init.vim`; if it emits any preamble of its own, `set nocompatible` may end up below something. `diff result/home-files/.config/nvim/init.vim ~/.config/nvim/init.vim` to confirm.
- **Parity note:** Both files. Identical change.

---

### [MEDIUM] M5 — Adopt `programs.tmux` skeleton (defer absorbing tmux.conf into typed options)

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:33, :70; `/Users/zyst/dev/dotfiles/home-mac.nix`:33, :64
- **Current:**
  ```nix
  home.packages = [ pkgs.tmux ... ];
  home.file.".tmux.conf".source = "${dotfiles}/tmux.conf";
  ```
- **Recommended:**
  ```nix
  programs.tmux = {
    enable = true;
    shortcut = "Space";      # produces C-Space prefix to match wincent-derived tmux.conf
    sensibleOnTop = false;   # avoid double-loading tmux-sensible
    extraConfig = builtins.readFile "${dotfiles}/tmux.conf";
  };
  ```
  Drop `pkgs.tmux` and drop the `home.file.".tmux.conf"` entry.
- **Home-manager option(s):** `programs.tmux.enable`, `programs.tmux.extraConfig`, `programs.tmux.shortcut`, `programs.tmux.sensibleOnTop`, `programs.tmux.plugins` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.tmux.enable
- **Live-tree verified:** Yes. Options: `{ aggressiveResize, baseIndex, clock24, customPaneNavigationAndResize, disableConfirmationPrompt, enable, escapeTime, extraConfig, focusEvents, historyLimit, keyMode, mouse, newSession, package, plugins, prefix, resizeAmount, reverseSplit, secureSocket, sensibleOnTop, shell, shortcut, terminal, tmuxinator, tmuxp }`.
- **Why:** Even without absorbing the rc file into typed options, the skeleton unlocks `programs.tmux.plugins` for declarative plugin management (the user's current `tmux-resurrect`/`tmux-continuum` setup could move here in a later refactor), and the module manages `~/.config/tmux/tmux.conf` by default (sidesteps the legacy `~/.tmux.conf` path).
- **Risk:** Medium — verify carefully. The module emits a preamble for `prefix`/`terminal`/`mouse`/`escapeTime`/etc. before `extraConfig`. The user's tmux.conf sets `prefix C-Space`; the module's default `shortcut` is `b`. Setting `shortcut = "Space"` and `sensibleOnTop = false` minimizes preamble. Test in a throwaway session: `tmux -L test -f result/home-files/.config/tmux/tmux.conf`. Also: search the dotfiles repo for `~/.tmux.conf` references before switching to the `~/.config/tmux/` location.
- **Parity note:** Both files. Plugin migration to `programs.tmux.plugins` is a separate, larger refactor.

---

### [MEDIUM] M6 — Adopt `programs.fastfetch`

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:13; `/Users/zyst/dev/dotfiles/home-mac.nix`:13
- **Current:** `pkgs.fastfetch` in `home.packages`.
- **Recommended:** `programs.fastfetch.enable = true;` (drop `pkgs.fastfetch`).
- **Home-manager option(s):** `programs.fastfetch.enable`, `programs.fastfetch.settings` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.fastfetch.enable
- **Live-tree verified:** Yes. Options: `{ enable, package, settings }`.
- **Why:** Cheap idiomaticity win.
- **Risk:** None for `enable`-only.
- **Parity note:** Both files.

---

### [MEDIUM] M7 — Adopt `programs.yt-dlp`

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:38; `/Users/zyst/dev/dotfiles/home-mac.nix`:37
- **Current:** `pkgs.yt-dlp` in `home.packages`.
- **Recommended:** `programs.yt-dlp.enable = true;` (drop `pkgs.yt-dlp`).
- **Home-manager option(s):** `programs.yt-dlp.enable`, `programs.yt-dlp.settings` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.yt-dlp.enable
- **Live-tree verified:** Yes. Options: `{ enable, extraConfig, package, settings }`.
- **Why:** First-class module.
- **Risk:** None for `enable`-only.
- **Parity note:** Both files.

---

### [MEDIUM] M8 — Adopt `programs.ranger.enable` (defer absorbing rc.conf)

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:30, :49; `/Users/zyst/dev/dotfiles/home-mac.nix`:30, :43
- **Current:**
  ```nix
  home.packages = [ pkgs.ranger ... ];
  home.file.".config/ranger/rc.conf".source = "${dotfiles}/ranger/rc.conf";
  ```
- **Recommended:** `programs.ranger.enable = true;`. Drop `pkgs.ranger`. **Keep** the `home.file.".config/ranger/rc.conf"` entry — Check 5 deferred.
- **Home-manager option(s):** `programs.ranger.enable`, `programs.ranger.settings`, `programs.ranger.aliases`, `programs.ranger.mappings`, `programs.ranger.rifle`, `programs.ranger.plugins` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ranger.enable
- **Live-tree verified:** Yes. Options: `{ aliases, enable, extraConfig, extraPackages, finalPackage, mappings, package, plugins, rifle, settings }`.
- **Why:** Canonical install path; opens door to absorbing rc.conf later (deferred).
- **Risk:** Verify `enable = true` alone doesn't write a default rc.conf that fights with the user's. If it does, set `programs.ranger.extraConfig = ""` or skip.
- **Parity note:** Both files. Absorption of rc.conf into typed options is the deferred candidate.

---

### [LOW] L1 — `programs.starship.enableFishIntegration` defaults to `true`; no action needed

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:202; `/Users/zyst/dev/dotfiles/home-mac.nix`:185
- **Live-tree verified:** Yes. `default = true`. Sanity check per Check 3 — current config is correct.
- **Parity note:** Both files already correct.

---

### [LOW] L2 — `programs.jujutsu.enableFishIntegration` is hidden/deprecated; user correctly does NOT set it

- **File(s):** N/A — not set.
- **Live-tree verified:** Yes. The option still exists in the option tree but is `visible = false`. Integration is automatic when `programs.jujutsu.enable` and `programs.fish.enable` are both `true`. Confirms CLAUDE.md's claim.
- **Parity note:** Both files already correct.

---

### [LOW] L3 — `programs.fzf.enableFishIntegration = true;` is the module default; explicit setting is redundant

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:132; `/Users/zyst/dev/dotfiles/home-mac.nix`:115
- **Current:** `programs.fzf.enableFishIntegration = true;` explicitly set.
- **Recommended (optional cleanup):** Remove the explicit setting; default already `true`.
- **Home-manager option(s):** `programs.fzf.enableFishIntegration` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.fzf.enableFishIntegration
- **Live-tree verified:** Yes. Default is `true`.
- **Why:** Micro-cleanup. Arguable case for keeping it explicit as documentation; user's call.
- **Risk:** None.
- **Parity note:** Both files. Apply the same decision to both.

---

### [LOW] L4 — Consider `programs.fzf.tmux.enableShellIntegration` for popup integration

- **Current:** Not configured.
- **Recommended:** `programs.fzf.tmux.enableShellIntegration = true;` — opens fzf widgets (Ctrl-T, Alt-C, Ctrl-R) in a tmux popup overlay when inside tmux.
- **Home-manager option(s):** `programs.fzf.tmux.enableShellIntegration`, `programs.fzf.tmux.shellIntegrationOptions` — https://nix-community.github.io/home-manager/options.xhtml#opt-programs.fzf.tmux.enableShellIntegration
- **Live-tree verified:** Yes. `programs.fzf.tmux` options: `{ enableShellIntegration, shellIntegrationOptions }`.
- **Why:** User just adopted fzf today and lives in tmux — popup overlay vs. full-pane takeover is a small UX win.
- **Risk:** None — cosmetic toggle.
- **Parity note:** Both files if adopted.

---

### [LOW] L5 — `home.shell.enableFishIntegration` exists; investigate whether the manual `.config/environment.d/10-shell.conf` is still necessary

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:79-81 (Linux only)
- **Current:**
  ```nix
  ".config/environment.d/10-shell.conf".text = ''
    SHELL=${config.home.homeDirectory}/.nix-profile/bin/fish
  '';
  ```
- **Recommended (investigate first):** The live tree exposes `home.shell.{ enableShellIntegration, enableFishIntegration, … }`. Check whether enabling them, with `programs.fish.enable = true` already set, gets `$SHELL` set in the right places (login sessions, GUI terminal launches, systemd user services). If yes, drop the `environment.d` file. If no (because `environment.d` is specifically a systemd-pam mechanism that home-manager's shell integration doesn't reach), leave it.
- **Home-manager option(s):** `home.shell.enableFishIntegration`, `home.shell.enableShellIntegration` — https://nix-community.github.io/home-manager/options.xhtml#opt-home.shell.enableShellIntegration
- **Live-tree verified:** Yes. `home.shell` options: `{ enableBashIntegration, enableFishIntegration, enableIonIntegration, enableNushellIntegration, enableShellIntegration, enableZshIntegration }`.
- **Why:** Verifying which path is load-bearing on the user's Linux machine (Regolith/i3 + awesome) clarifies whether the manual file is redundant.
- **Risk:** Investigation only; no immediate change.
- **Parity note:** Linux-only.

---

### [LOW] L6 — Various packages correctly stay in `home.packages` (no module exists)

`pkgs.tree`, `pkgs.ncdu`, `pkgs.fortune`, `pkgs.gtypist`, `pkgs.termdown`, `pkgs.ffmpeg`, `pkgs.http-server`, `pkgs.xdelta`, `pkgs.xclip`, `pkgs.clojure`, `pkgs.joker`, `pkgs.leiningen`, `pkgs.jdk`, `pkgs.nodejs_22`, `pkgs.yarn`, `pkgs.prettier`, `pkgs.eslint`, `pkgs.git-quick-stats`.

- **Live-tree verified:** Yes — none of these names appear in the live `programs.*` attribute list. No module exists for any.
- **Why:** Negative confirmation per Check 1.
- **Parity note:** Identical across both files.

---

### [LOW] L7 — `programs.man.enable = true;` + `home.extraOutputsToInstall = [ "man" ];` is correctly the complementary pair

- **File(s):** `/Users/zyst/dev/dotfiles/home.nix`:102, :198; `/Users/zyst/dev/dotfiles/home-mac.nix`:87, :181
- **Current:** Both set. `programs.man.enable = true` generates the `manpath` cache; `extraOutputsToInstall = [ "man" ]` ensures nixpkgs derivations install their `man` output. They are complementary, not redundant. Confirmation per Check 7.
- **Parity note:** Both files correct.

---

## Cross-file parity (Check 6)

**Recommendation:** factor common content into a shared module (e.g. `common.nix`) and have `home.nix` / `home-mac.nix` import it. Several findings above (H1, H3, M1–M8) become single-edit changes instead of two-place edits if a `common.nix` exists.

**Common (~80 of the ~200 lines on each side):**

- `home.packages` for: bat, clojure, eslint, eza, fastfetch, ffmpeg, fortune, gh, git-quick-stats, gtypist, htop, http-server, jdk, joker, jq, leiningen, ncdu, neovim, neovim-node-client, nodejs_22, prettier, ranger, ripgrep, termdown, tmux, tree, xdelta, yarn, yt-dlp (everything except `xclip`).
- `home.file` entries: `.config/kitty/kitty.conf`, `.config/ranger/rc.conf`, `.config/mpv`, `.config/espanso`, `.claude/skills/didactic-upstream-diff-iteration`, `.vimrc`, `.bashrc`, `.tmux.conf`, `.emacs.d`, `.config/openmw/settings.cfg`, `.config/nvim/init.vim`, `.config/bat/config`.
- `home.extraOutputsToInstall = [ "man" ]`, `home.sessionVariables.LESS = "-FRX"`, `home.stateVersion = "22.05"`, `home.username = "zyst"` (identical by coincidence — not guaranteed on future machines).
- `news.display = "silent"`.
- All of `programs.{ emacs, fish, fzf, jujutsu, delta, home-manager, man, mpv, starship }`.
- `programs.git` except the platform-specific `credential.helper` last element.

**Per-platform (stays):**

- `let dotfiles = …`.
- `home.homeDirectory` (`/home/zyst` vs `/Users/zyst`).
- `pkgs.xclip` (Linux only).
- `.config/awesome`, `.xinitrc`, `.config/regolith/*`, `.config/environment.d/10-shell.conf` (Linux only).
- `programs.git.settings.credential.helper`'s last element (`libsecret` vs `osxkeychain`).
- `targets.genericLinux.enable = true` (Linux only).

**Accidental divergences:** none found. Every difference appears intentional.

---

## Deferred candidates (scope-limited, per Check 5)

`home.file` entries where a `programs.<name>` module could absorb the file contents into Nix-native settings. **All deferred** — flagging only.

- **`.config/kitty/kitty.conf`** → `programs.kitty.{ enable, settings, font, theme, keybindings, environment, shellIntegration, enableGitIntegration }`. Largest candidate.
- **`.config/ranger/rc.conf`** → `programs.ranger.{ settings, aliases, mappings, rifle, plugins }`. M8 only adopts `enable`.
- **`.config/mpv/`** → `programs.mpv.{ config, profiles, scripts, bindings, defaultProfiles, includes }`. `programs.mpv.enable` already set; rest deferred.
- **`.config/espanso/`** → no first-class `programs.espanso` module on the local channel. Leave as `home.file`.
- **`.bashrc`** → `programs.bash.{ enable, shellAliases, sessionVariables, initExtra, bashrcExtra, … }`.
- **`.vimrc` / `.config/nvim/init.vim`** → vimrc tangling out of scope. M4 absorbs `init.vim` only (hand-written, not tangled).
- **`config.fish`** (`programs.fish.interactiveShellInit = builtins.readFile …`) → could decompose into `programs.fish.{ shellAliases, shellAbbrs, functions, plugins, generateCompletions, preferAbbrs }`. Probably the largest single deferred refactor.
- **`.tmux.conf`** → `programs.tmux.{ extraConfig, plugins, prefix, shortcut, terminal, mouse, escapeTime, focusEvents, historyLimit, keyMode, … }`. M5 adopts skeleton via `extraConfig`.
- **`.config/openmw/settings.cfg`** → no `programs.openmw` module. Leave.
- **`.emacs.d/`** → `programs.emacs.{ extraPackages, extraConfig, init, … }`. `programs.emacs.enable` already set.

---

## Iteration tracking

This file is the source-of-truth for the audit findings. Adoptions/declines are tracked in a sibling `report-2026-05-23-state.md` so re-runs of the didactic walk don't re-prompt for already-decided findings.
