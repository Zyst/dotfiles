# Dotfiles — Claude project context

This file is the portable, machine-independent source of truth for how Claude should work on this repo. Memory under `~/.claude/projects/-Users-zyst/memory/` is per-machine and won't follow this repo to a new laptop — this file does. When setting up a new machine, this is the bootstrap context.

## Sync rule

Whenever a dotfile-related fact is added/updated/removed in user memory (`~/.claude/projects/-Users-zyst/memory/`), mirror the change to the appropriate in-repo file in the same edit. The two should not drift.

The in-repo source-of-truth depends on the fact type:

- **Conventions, gotchas, architecture, principles** → this file (`.claude/CLAUDE.md`).
- **TODOs** → `.claude/todos/{todos,linux,mac}.md` (generic / Linux / Mac).

The reverse also applies: if you add a new dotfiles fact to this file (or to `.claude/todos/*.md`) and no memory entry exists yet, add one under `~/.claude/projects/-Users-zyst/memory/` and link it in `MEMORY.md`.

## Path conventions

This repo ships to multiple machines (macOS, Linux, WSL) with different `$HOME` values, hostnames, and project locations. Anything written into a repo-versioned file must use **abstract paths** — `$HOME`, `~`, the `${dotfiles}` Nix let-binding, repo-relative paths, or prose ("Claude's memory directory," "this prompt's sibling file"). Hardcoded `/Users/<name>/...` or machine-specific project IDs do not belong in tracked files (the `home.homeDirectory` value in each `home-*.nix` entrypoint is the deliberate exception — that's the machine-specific anchor; everything else, including the `${dotfiles}` path itself, is derived from it. `home-wsl.nix` still hardcodes its own `let dotfiles = "..."` until it adopts `common.nix`).

Existing references like `~/dev/dotfiles/` are technically machine-specific too and should migrate toward "the dotfiles repo root" phrasing over time.

## Privacy: keep professional/workplace context out of tracked files

This repo is **public** (`github.com/Zyst/dotfiles`); anything committed is visible to anyone, indefinitely. **Never speculate about or reference the user's professional context** in tracked files. Frame blockers and motivations as neutral surface facts: state *what* is uncertain or pending, not *who* gates it or *why* it might be gated.

Even negative examples (e.g. a "don't write X" entry that quotes X) inscribe the leaking phrasing into the public file and are not safe — describe the rule abstractly rather than illustrating with a concrete bad version. If a fact only makes sense with workplace context attached, it doesn't belong in a tracked file at all. Such context can still inform *conversational* reasoning, and per-machine memory under `~/.claude/projects/-Users-zyst/memory/` is a fine home for it.

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
- **Describe current state only in human-facing dotfiles.** In `vimrc.org` and other human-facing config files, do **not** include historical / comparative framing: "replacing X", "we switched from Y", "X was the previous option", "in case we want to revert", "the older Z option was removed in vN". Commits already document those transitions; embedding them in the file accumulates cruft. Prefer: "We use X for Y", current-tense state descriptions. Commented-out alternative `Plug` lines don't need prose justification — the commit history explains why they're parked. (This rule does NOT apply to `.claude/`-internal files — those use the denser AI-facing style with explicit "Why:" annotations and historical context. See the next subsection.)
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

`tmux-resurrect` + `tmux-continuum` auto-save tmux state every 15 minutes to `~/.local/share/tmux/resurrect/`, with a `last` symlink pointing at the most recent save. The dominant failure mode is **`last` becomes a 0-byte file, next launch restores nothing (or instantly exits)**. Two distinct upstream bugs both produce this symptom, plus a third one-off mode.

### Root causes for 0-byte `last`

1. **Boot-race (tmux-continuum PR #159, open/unmerged)** — when `@continuum-boot 'on'` is set, systemd auto-starts tmux at login. Status-bar interpolation fires `continuum_save.sh` on the first status refresh (sub-second after server start), but `continuum_restore.sh` is backgrounded and slower. If save runs before restore has populated sessions, `tmux list-sessions`/`list-panes` produce no output. `tmux-resurrect/scripts/save.sh:242` is `fetch_and_dump_grouped_sessions > "$resurrect_file_path"` — the `>` truncates the file unconditionally, so a no-output dump leaves a 0-byte file. Then `save.sh:247` compares it to `last` via `cmp`, finds them different (0 bytes ≠ the previous non-empty save), and `ln -fs` repoints `last` at the new empty file. References: PR #159, issues #90/#94/#152.

2. **Shutdown ExecStop bomb** — when `@continuum-boot 'on'` runs `systemd_enable.sh`, it writes `~/.config/systemd/user/tmux.service` with `KillMode=control-group` + `ExecStop=/.../tmux-resurrect/scripts/save.sh`. On unit stop, KillMode kills the tmux server cgroup *first*, then ExecStop runs save.sh against an already-dead server. The journal shows ~13 lines of `no server running on /tmp/tmux-1000/default` from the save.sh subprocess fan-out, save.sh exits non-zero, **but the 0-byte file is still created** (the truncating `>` runs before save.sh notices the missing server). `last` gets repointed on every reboot/logout under this configuration.

Both modes are gated on `@continuum-boot 'on'`. With it off, neither systemd auto-start nor the ExecStop bomb can fire. We pin `set -g @continuum-boot 'off'` explicitly in `tmux.conf` (rather than relying on the upstream default) so a future default flip or an accidental re-enable doesn't reintroduce the unit.

3. **Mid-session 0-byte saves (rare, root cause unknown)** — seen 2026-05-22 with two 0-byte saves at 22:54 and 23:13 inside a single 22:33→00:26 boot session. Not boot-race (uptime ≥20 min) and not shutdown (server still alive). Possibly `dump_state` transiently failing or a lock-race, but not reproduced. If you see a 0-byte save with neither boot-race nor ExecStop timing, this is the bucket; recovery procedure below still applies.

### Symptom + recovery procedure

- **Symptom:** Launching `tmux` (or `tmux attach`) from a fresh shell either instantly exits (sometimes after a brief `Restoring...` status line) or comes up with an empty/bootstrap session instead of the previous one. Under Wayland the same root cause may surface as a TPM "exited with code 1" toast just before the session dies. Confirmed during the 2026-05-22 → 2026-05-29 stretch on Linux.
- **How to debug:**
  1. `ls -la ~/.local/share/tmux/resurrect/last` — note the symlink target.
  2. `ls -la $(readlink -f ~/.local/share/tmux/resurrect/last)` — check size. 0 bytes = bug.
  3. `ls -t ~/.local/share/tmux/resurrect/tmux_resurrect_*.txt | head -5` — find the most recent non-empty save (usually within one 15-min auto-save tick).
  4. `systemctl --user is-enabled tmux.service` — anything other than `not-found` means the ExecStop bomb may still be wired up. Also `ls ~/.config/systemd/user/tmux.service` — if the file exists, the bomb is one `systemctl --user enable` away from re-arming.
  5. **Watch for home-manager-switch lag:** if you just changed tmux.conf and the bug still recurs after reboot, the new config may not be live yet. `~/.tmux.conf` is a nix-store symlink and only updates when `home-manager switch` runs — reboots alone don't re-evaluate. Check `home-manager generations | head -3` against the commit time, and `grep -L '<your change>' /nix/store/*-hm_tmux.conf` to spot stale store paths. This cost two days during the 2026-05-29 investigation: the May 27 commit didn't land until the May 29 10:09 switch, and every boot in between recreated the bomb.
- **How to fix `last`:**
  ```
  cd ~/.local/share/tmux/resurrect
  rm last
  ln -s tmux_resurrect_<good-timestamp>.txt last
  rm tmux_resurrect_<empty-timestamp>.txt    # optional, tidies the dir
  ```
  Restores the previous good snapshot; you lose at most one auto-save interval (≤15 min) of state. Verify with `tmux new-session -d -s verify && tmux ls` — the session should stay alive.
- **How to remove the systemd unit entirely** (defuses the ExecStop bomb permanently as long as `@continuum-boot 'off'` stays pinned):
  ```
  rm -f ~/.config/systemd/user/tmux.service ~/.config/systemd/user/default.target.wants/tmux.service
  systemctl --user daemon-reload
  systemctl --user is-enabled tmux.service    # should print: not-found
  ```
  If anything ever flips `@continuum-boot` back to `'on'`, continuum's `systemd_enable.sh` will rewrite the unit file with the same broken template — that's an upstream design flaw, not patched locally.
- **macOS counterpart — `Tmux.Start.plist` launch agent.** On macOS, tmux-continuum installs a LaunchAgent at `~/Library/LaunchAgents/Tmux.Start.plist` (label literally `Tmux.Start.plist`, not reverse-DNS) pointing at `~/.tmux/plugins/tmux-continuum/scripts/handle_tmux_automatic_start/osx_terminal_start_tmux.sh`. The script auto-starts tmux when Terminal.app/Kitty/iTerm launches at login — same role as the Linux systemd unit, same boot-race exposure when `@continuum-boot 'on'`. Two failure shapes to watch:
  1. **File deleted but launchctl still tracks it.** Removing the `.plist` from disk doesn't unload it — `launchctl list | grep -i tmux` will still show `Tmux.Start.plist` until you explicitly `bootout`. Symptom: file is gone but the agent fires anyway on next login.
  2. **File still present.** `find ~/Library /Library 2>/dev/null -iname '*tmux*plist'` shows where it lives.
  Removal procedure:
  ```
  launchctl bootout gui/$(id -u)/Tmux.Start.plist 2>/dev/null    # exit 0 even if file already gone
  rm -f ~/Library/LaunchAgents/Tmux.Start.plist
  launchctl list | grep -i tmux                                  # should print nothing
  ```
  Same upstream caveat as Linux: if `@continuum-boot` flips back to `'on'`, the agent gets reinstalled with the same template.
- **What does NOT help, so skip these as a first move:** reinstalling all plugins (`prefix + I` / `prefix + alt + u`), clearing `~/.tmux/plugins/`, rebuilding tmux, restarting the display manager. If `last` is the corruption, none of these touch it; if `last` is fine, look elsewhere.

### Stray `pmset: command not found` on Linux

Unrelated but adjacent — tmux-continuum invokes `pmset` (macOS-only) on every interval and on certain hooks, visible as `/bin/bash: line 1: pmset: command not found` in output captured from non-TTY tmux invocations on Linux. Harmless noise. Worth flagging because it shows up in any captured-output debug session and looks alarming; it is not the culprit for startup failures.

## AeroSpace (macOS) — native-fullscreen workspace-switch gotcha

`programs.aerospace` in `home-mac.nix` drives the Mac tiling WM. One known behavior, **investigated 2026-06-06 and accepted as won't-fix:**

**Symptom:** with a window in *macOS native* fullscreen (green button / `Ctrl+Cmd+F` / F11 — e.g. a fullscreened Chrome), the `cmd-N` workspace binding (`home-mac.nix:79-88`) needs **two presses** to land on that workspace. The first press jumps to the wrong workspace (another window); a second `cmd-N` in quick succession resolves it.

**Root cause (not a config bug):** macOS native fullscreen moves the window into its own dedicated macOS *Space*. AeroSpace deliberately emulates all its workspaces inside a *single* macOS Space and avoids native Spaces, because native Space-switching has a slow animation macOS won't let you fully disable. So a native-fullscreen window lives outside AeroSpace's model — the first `cmd-N` races against the macOS Space-switch animation and mis-lands; the second press completes once it settles. Confirmed against the [AeroSpace guide](https://nikitabobko.github.io/AeroSpace/guide) ("native macOS Spaces have a lot of problems … animations that cannot be fully disabled").

**Space-free alternative (already bound):** `alt-f = "fullscreen"` (`home-mac.nix:103`) is AeroSpace's *in-workspace* fullscreen — fills the workspace with no separate Space, so `cmd-N` stays single-press. **But** it's geometry-only: it can't tell Chrome to hide its toolbar/tab strip, which is why native fullscreen was preferred here. The only ways to get a chromeless Chrome window *without* native fullscreen are app-mode windows (`--app=URL` / "Install as app" — no tab strip, tiles normally) or accepting the toolbar. The user weighed both and chose to **keep native fullscreen and live with the double-tap** rather than switch to app-mode windows.

**Mitigations tried:**
- *Reduce Motion* (System Settings → Accessibility → Display) is **already enabled** and shortens the Space-switch animation — the double-tap persists anyway, so it's a property of the native-Space transition itself, not just the animation length.
- *Disabling "Displays have separate Spaces"* (Desktop & Dock → Mission Control, logout to apply) — AeroSpace's own recommendation, but **tried 2026-06-06 and it made things worse, so it was reverted.** With it off you can switch *to* the fullscreen workspace (Workspace 1), but then get **stuck unable to leave it** — `cmd-N` to any other workspace no-ops until you first switch to another Chrome/native-fullscreen workspace, then onward. Net regression vs. the plain double-tap, which at least always moves. Left **on** (the macOS default).

**Candidate fix not yet adopted — double-send the switch (`cmd-N = ["workspace N", "workspace N"]`):** the idea is to automate the manual double-tap. Docs-checked tradeoffs ([AeroSpace commands](https://nikitabobko.github.io/AeroSpace/commands)):
- *Safe re: back-and-forth* — `workspace N` while already on N is a **no-op** by default (NOT a toggle), so the redundant second send is harmless in the normal non-fullscreen case. This only holds as long as we never add the `--auto-back-and-forth` flag, which would turn the second send into a bounce-to-previous. Don't add it.
- *Likely ineffective + the real risk* — the manual fix works because of the human gap between presses (the Space animation has progressed by the second tap). A binding's command array runs **sequentially with no documented inter-command delay**, so both sends fire near-instantly, both race the *same* animation, and may both mis-land — i.e. it might not reproduce the fix at all while doubling every switch.
- *To force a gap* you'd need a hack: make the second element `exec-and-forget sleep 0.15 && aerospace workspace N`, which forks a shell on every workspace press. Ugly; not worth it unless testing proves the plain double-send fails.
- **Verdict (2026-06-06): considered and rejected.** Cheap to try (just duplicate the command, no `--auto-back-and-forth`), but the no-delay timing means it likely wouldn't land anyway, and the reliable variant needs the per-press `sleep`+CLI fork. The user judged the downside not worth it over the plain double-tap, which always moves. Revisit only if AeroSpace later adds an inter-command delay or a native-fullscreen-aware focus.

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

- `common.nix` — shared module imported by the Mac and Linux entrypoints. Holds packages, `home.file`, `programs.*`, etc. that are identical across both. Derives `dotfiles = "${config.home.homeDirectory}/dev/dotfiles"` from `home.homeDirectory`, so it stays portable across the differing `$HOME` paths.
- `home.nix` — Linux entrypoint. `imports = [ ./common.nix ]` plus Linux-only deltas: `home.homeDirectory`, Linux-only packages (`wl-clipboard`, `xclip`), Linux-only `home.file` entries (awesome / regolith / `.xinitrc` / `environment.d`), `targets.genericLinux.enable`, `programs.git.settings.credential.helper = [ "libsecret" ]`.
- `home-mac.nix` — macOS entrypoint (symlinked into `~/.config/home-manager/home.nix` on the current Mac). `imports = [ ./common.nix ]` plus Mac-only deltas: `home.homeDirectory`, `caffeine` package + `Applications/Caffeine.app` link, `programs.aerospace`, `programs.git.settings.credential.helper = [ "osxkeychain" ]`.
- `home-wsl.nix` — WSL entrypoint. **Still standalone** — does not yet `imports` `common.nix` (deferred per the WSL catch-up TODO).

Mac and Linux are now `imports`-chained through `common.nix`; WSL remains a standalone config until its own catch-up pass adopts the same shape. When adding a package or option, prefer putting it in `common.nix` unless it's genuinely platform-specific. Platform-conflicting options (e.g. git's `credential.helper`, which is a list-merged attribute) must stay in the platform files only — adding them to `common.nix` would concatenate both helpers on every platform.

## Open dotfile-related TODOs

Live in sibling files under `.claude/todos/`:

- `.claude/todos/todos.md` — generic / cross-platform dotfile TODOs
- `.claude/todos/linux.md` — Linux-specific
- `.claude/todos/mac.md` — macOS-specific (created on-demand when a Mac TODO surfaces; absent when there are none)

Each file is the canonical, in-repo source for its scope. Memory's `~/.claude/projects/-Users-zyst/memory/todos.md` mirrors items per the Sync rule above, but the in-repo files are the primary surface — they survive an OS hop, while memory is per-machine. Done items get deleted outright (see `feedback_todo_deletion.md` in memory).

## Related repo conventions

- Per-app config dirs (`alacritty.yml`, `kitty.conf`, `i3.config`, `espanso/`, `mpv/`, `awesome/`, `openmw/`, `BAR/`, etc.) are wired up via home-manager — check the relevant `home*.nix` to see how a given file lands in `$HOME`.
- **X11-era WM configs are semi-abandoned** as of 2026-05-24: `i3.config`, `awesome/`, `Xresources-regolith`, `.xinitrc`. The Linux side is migrating to Sway from-scratch (see `.claude/todos/linux.md`); when porting bindings to the new Sway config, **Regolith's upstream Sway/i3 configs are the canonical reference**, not the local files. Local `i3.config` is consulted only for the Colemak-DH directional bindings (`i3.config:112-116, 171-175`) that Regolith doesn't ship.
- **Notification primitive is `noti`** (adopted 2026-05-24). Installed cross-platform via `home.packages` in `home.nix` + `home-mac.nix`. Bypasses terminal-escape protocols (OSC 9 / OSC 99 / `kitten notify`) entirely — those don't reliably traverse tmux+Kitty on macOS even with `allow-passthrough all` (known issues: [kitty#8090](https://github.com/kovidgoyal/kitty/issues/8090), [kitty#8086](https://github.com/kovidgoyal/kitty/issues/8086), [claude-code#19976](https://github.com/anthropics/claude-code/issues/19976)). `noti` calls macOS's UserNotifications and Linux's libnotify natively. CLI: `noti -t Title -m Message` or `noti some-long-command` to fire on completion.

### Local skills

Reusable Claude Code interaction skills live under `.claude/skills/` in this repo and are symlinked into `$HOME/.claude/skills/` via home-manager (look for the matching `home.file` entry in each `home-*.nix`). They are available to every Claude Code session regardless of working directory.

- **`didactic-upstream-diff-iteration`** (`.claude/skills/didactic-upstream-diff-iteration/SKILL.md`) — one-at-a-time review pattern for upstream-config audits and similar batched-change tasks. Per-candidate Adopt / Decline / Skip prompts, confirm-or-back-out on adopt, persistent rejection list so declined items don't re-surface. Used by `.claude/agents/tmux-upstream-audit/agent-prompt.md`.
