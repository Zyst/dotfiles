# Dotfiles — agent instructions

This file is the portable, shared source of truth for agents working in this repository. Read the relevant notes and TODOs before proposing broader work. Claude-specific instructions live in `.claude/CLAUDE.md`, which imports this file.

## Durable notes and task scope

Keep shared facts in the repository so they survive a change of machine or coding agent:

- **Conventions, architecture, working rules** → `AGENTS.md`.
- **Detailed troubleshooting and accepted tool behavior** → `.agents/notes/`.
- **TODOs** → `.agents/todos/{todos,linux,nvim}.md`; create other platform lists only when needed.
- **Audit procedures, findings, and adoption/rejection decisions** → `.agents/audits/`.

Agent-local memory can mirror these files but is not required to read or maintain them. Claude's memory synchronization rules stay in `.claude/CLAUDE.md`.

TODO backlogs, audit prompts, and embedded resumption prompts are reference material; do not execute them unless the user requests that work. Read audit state/rejection records before presenting recommendations so accepted or declined decisions are not reopened automatically. Remove completed TODOs; preserve durable decisions in the appropriate notes or audit state.

For Home Manager proposals, read `.agents/audits/home-manager-audit/state.md` before its historical `report.md`. Preserve the recorded preference for portable `tmux.conf` and deliberately simple package declarations; a module recommendation in the report is not an adoption decision.

## Path conventions

This repo ships to multiple machines (macOS, Linux, WSL) with different `$HOME` values, hostnames, and project locations. Anything written into a repo-versioned file must use **abstract paths** — `$HOME`, `~`, the `${dotfiles}` Nix let-binding, repo-relative paths, or prose ("Claude's memory directory," "this prompt's sibling file"). Hardcoded `/Users/<name>/...` or machine-specific project IDs do not belong in tracked files (the `home.homeDirectory` value in each `home-*.nix` entrypoint is the deliberate exception — that's the machine-specific anchor; everything else, including the `${dotfiles}` path itself, is derived from it).

Existing references like `~/dev/dotfiles/` are technically machine-specific too and should migrate toward "the dotfiles repo root" phrasing over time.

## Privacy: keep professional/workplace context out of tracked files

This repo is **public** (`github.com/Zyst/dotfiles`); anything committed is visible to anyone, indefinitely. **Never speculate about or reference the user's professional context** in tracked files. Frame blockers and motivations as neutral surface facts: state *what* is uncertain or pending, not *who* gates it or *why* it might be gated.

Even negative examples (e.g. a "don't write X" entry that quotes X) inscribe the leaking phrasing into the public file and are not safe — describe the rule abstractly rather than illustrating with a concrete bad version. If a fact only makes sense with workplace context attached, it doesn't belong in a tracked file at all. Such context can still inform conversational reasoning or private, agent-local memory.

## Source of truth

- Repo: `https://github.com/Zyst/dotfiles`, cloned to `~/dev/dotfiles/`.
- Managed via Nix + Home Manager, using the platform entrypoint linked at `~/.config/home-manager/home.nix`.
- Files in `$HOME` (`~/.vimrc`, `~/.zshrc`, `~/.config/...`) are read-only symlinks/copies produced by home-manager. **Never edit them directly** — they will be overwritten on the next rebuild, and most are literally read-only.
- When diagnosing: read from `$HOME` (that's the live config), but make the fix in `~/dev/dotfiles/` and cite line numbers from the source.
- When suggesting a tool install, frame it as a home-manager package addition, not `brew install` or similar.

## Version control: jj on top of git

This repo is **jj-managed** — `.jj/` exists alongside `.git/`, the git remote `origin` (`github.com/Zyst/dotfiles`) is what we push to, but locally we drive everything through jj. Default to `jj` surface commands, **not** `git`, for any work here.

Standard commit-and-push flow:

Push only when the user explicitly requests it. The commands below describe the workflow, not standing permission to publish changes.

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

**Commit-message style:** see recent `jj log` output. Short, lowercase verb start, optional file-prefix (e.g. `home-wsl: ...`), no `Co-Authored-By:` trailers. Match the existing local style.

## `home-manager switch` workflow

For most files (non-tangled): edit the source in `~/dev/dotfiles/`, then `home-manager switch` to relink `$HOME`.

### Gotcha — home-manager's own config

home-manager reads from `~/.config/home-manager/home.nix`, **not** directly from the dotfiles repository. That path must link to the platform entrypoint (`home.nix`, `home-mac.nix`, or `home-wsl.nix`) so source edits propagate automatically. Verify the link on the current machine.

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

`programs.neovim` in `common.nix` explicitly sets `withPython3 = false; withRuby = false;` (introduced 2026-05-23 as part of the `programs.neovim` adoption). The user's current plugin set doesn't need either provider — but if you add a plugin that relies on `:python3 ...` / `:ruby ...` or declares `if has('python3')`, those calls will fail until you flip the relevant flag back to `true`.

Symptom to watch for: `:checkhealth provider` reporting `provider.python3` or `provider.ruby` as missing AND a plugin you just installed throwing errors referencing those features.

Fix: in `common.nix`, change `withPython3 = false;` (or `withRuby = false;`) to `true`, then `home-manager switch`. The wrapper picks up the appropriate `/nix/store/.../nvim-host-python3-…/bin` (or ruby) path on next nvim launch.

Common plugins that need python3: UltiSnips, older YouCompleteMe, denite/defx, some completion sources. Common plugins that need ruby: vim-rails, vim-ruby-refactoring. None of these are in the current `vimrc.org`.

### Special case — vim-plug plugin branch/version changes

vim-plug does **not** auto-switch the branch of an already-checked-out plugin when you change the `Plug` line. After steps 1–3 above, also:

```
rm -rf ~/.config/nvim/plugged/<plugin>
nvim --headless '+PlugInstall --sync' '+qa'    # run from a valid cwd like ~
```

## Voice and tone for comments / documentation

Two audiences read this repo, with different expectations:

**Human-facing files** — `vimrc.org`, `tmux.conf`, `home.nix` / `home-mac.nix` / `home-wsl.nix`, `config.fish`, `kitty/kitty.conf`, `bashrc`, the various per-app config dirs, `README.md`. These belong to the user and stay visible while editing. When adding comments or prose, **read a few surrounding paragraphs first and match their voice**. The user has spotted tone-mismatch before and asked for rewrites, so this is a real concern, not cosmetic.

- `vimrc.org` is light and chatty — "We enable X for Y", "We also want Z", short sentences, occasional first-person plural. A multi-bullet block with bolded **Field:** labels stands out as alien.
- **Describe current state only in human-facing dotfiles.** In `vimrc.org` and other human-facing config files, do **not** include historical / comparative framing: "replacing X", "we switched from Y", "X was the previous option", "in case we want to revert", "the older Z option was removed in vN". Commits already document those transitions; embedding them in the file accumulates cruft. Prefer: "We use X for Y", current-tense state descriptions. Commented-out alternative `Plug` lines don't need prose justification — the commit history explains why they're parked. (This rule does NOT apply to agent notes — those use the denser AI-facing style with explicit "Why:" annotations and historical context. See the next subsection.)
- `tmux.conf` is one-or-two-line comments, often self-referential ("`^space ^space` is awfully close to..."). Multi-paragraph technical justifications belong in `.agents/notes/tmux.md`.
- `home*.nix` is largely code-only — no comments at all in long stretches. Don't introduce explanatory comments just because a change feels non-obvious; if the code itself is clear, leave it.
- If a thorough explanation is genuinely needed but doesn't fit the local voice, keep the inline note short and put the depth in `.agents/notes/` (or a `.agents/todos/*.md` file), then link from the inline comment.

**Agent-facing files** — `AGENTS.md`, `.agents/{notes,todos,audits}/`, and Claude-specific instructions/skills under `.claude/`. These are for AI agents, not for humans to read at editing time. **Verbosity, dense bold-field structure, and exhaustive context are helpful here** because they get re-read fresh by an LLM each session. Match the existing note format (e.g., **Status:** / **Why:** / **How to apply:** triads for TODOs); don't trim or "humanize" these the way you would a `vimrc.org` comment. Keep detailed tool history in linked notes so the main instructions stay focused.

## Tool-specific notes

Before changing tmux, read [the tmux notes](.agents/notes/tmux.md) for upstream lineage, accepted behavior, and session recovery procedures. Before changing AeroSpace, read [the AeroSpace notes](.agents/notes/aerospace.md), including the accepted fullscreen limitation and rejected mitigations.

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

- `common.nix` — shared module imported by the Mac, Linux, and WSL entrypoints. Holds shared packages, `home.file`, and `programs.*` settings. Derives `dotfiles = "${config.home.homeDirectory}/dev/dotfiles"` from `home.homeDirectory`, so it stays portable across the differing `$HOME` paths.
- `home.nix` — Linux entrypoint. `imports = [ ./common.nix ]` plus Linux-only deltas: `home.homeDirectory`, Linux-only packages (`wl-clipboard`, `xclip`), Linux-only `home.file` entries (awesome / regolith / `.xinitrc` / `environment.d`), `targets.genericLinux.enable`, `programs.git.settings.credential.helper = [ "libsecret" ]`.
- `home-mac.nix` — macOS entrypoint (symlinked into `~/.config/home-manager/home.nix` on the current Mac). `imports = [ ./common.nix ]` plus Mac-only deltas: `home.homeDirectory`, `caffeine` package + `Applications/Caffeine.app` link, `programs.aerospace`, `programs.git.settings.credential.helper = [ "osxkeychain" ]`.
- `home-wsl.nix` — WSL entrypoint. `imports = [ ./common.nix ]` plus `home.homeDirectory`, `targets.genericLinux.enable`, and packages: `gcc` for Treesitter parser compilation, `gnumake` for LuaSnip build hooks, `unzip` for Mason downloads, `typescript`, `wl-clipboard`, and `xclip`. GitHub HTTPS credentials use the shared `programs.gh` helper; no Windows Git credential-manager path is required.

All three platform entrypoints import `common.nix`. When adding a package or option, prefer putting it in `common.nix` unless it's genuinely platform-specific. Platform-conflicting options (e.g. git's `credential.helper`, which is a list-merged attribute) must stay in the platform files only — adding them to `common.nix` would concatenate both helpers on every platform.

On WSL, **keep the Kitty application outside Nix/Home Manager**; the manual installation is an intentional exception due to prior GPU-driver problems. Home Manager manages its configuration, themes, and paste hook through the `kitty/` directory. Fish is installed/configured by the shared module; registering it in `/etc/shells` and changing the account login shell with `chsh` are separate system-level bootstrap steps.

## Open dotfile-related TODOs

Live under `.agents/todos/`:

- `.agents/todos/todos.md` — generic / cross-platform dotfile TODOs
- `.agents/todos/linux.md` — Linux-specific
- `.agents/todos/nvim.md` — Neovim project decisions and remaining work
- `.agents/todos/mac.md` — macOS-specific (created on-demand when a Mac TODO surfaces; absent when there are none)

Each file is the canonical, in-repo source for its scope. Agent-local memory can mirror these files. Done items get deleted outright; preserve lasting decisions in notes or audit state before removing the task.

## Related repo conventions

- Per-app config dirs (`alacritty.yml`, `kitty/`, `i3.config`, `espanso/`, `mpv/`, `awesome/`, `openmw/`, `BAR/`, etc.) are wired up via home-manager — check the relevant `home*.nix` to see how a given file lands in `$HOME`.
- **X11-era WM configs are semi-abandoned** as of 2026-05-24: `i3.config`, `awesome/`, `Xresources-regolith`, `.xinitrc`. The Linux side is migrating to Sway from-scratch (see `.agents/todos/linux.md`); when porting bindings to the new Sway config, **Regolith's upstream Sway/i3 configs are the canonical reference**, not the local files. Local `i3.config` is consulted only for the Colemak-DH directional bindings (`i3.config:112-116, 171-175`) that Regolith doesn't ship.
- **Notification primitive is `noti`** (adopted 2026-05-24). Installed cross-platform via `home.packages` in `home.nix` + `home-mac.nix`. Bypasses terminal-escape protocols (OSC 9 / OSC 99 / `kitten notify`) entirely — those don't reliably traverse tmux+Kitty on macOS even with `allow-passthrough all` (known issues: [kitty#8090](https://github.com/kovidgoyal/kitty/issues/8090), [kitty#8086](https://github.com/kovidgoyal/kitty/issues/8086), [claude-code#19976](https://github.com/anthropics/claude-code/issues/19976)). `noti` calls macOS's UserNotifications and Linux's libnotify natively. CLI: `noti -t Title -m Message` or `noti some-long-command` to fire on completion.
