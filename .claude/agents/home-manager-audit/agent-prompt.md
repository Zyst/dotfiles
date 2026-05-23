# Audit Brief — home.nix / home-mac.nix idiomaticity

## Context

The user maintains their dotfiles at `~/dev/dotfiles` via Nix + home-manager. Two top-level home-manager configs drive everything: `home.nix` (Linux) and `home-mac.nix` (macOS, currently active). Both have grown organically — adding packages to `home.packages` and writing config files via `home.file."…".source` — without consistently reaching for the first-class `programs.<name>` modules home-manager exposes. The user wants an AI agent to audit both files and produce a written report identifying where the configs could become more idiomatic to home-manager, citing the official options reference for each finding.

Outcome: a ranked list of recommended changes the user can apply selectively. The agent does **not** edit files or run `home-manager switch` — this is a read-only audit.

## Mission

Audit `~/dev/dotfiles/home.nix` and `~/dev/dotfiles/home-mac.nix` and produce a written report of idiomaticity improvements. For each finding, cite the relevant home-manager option(s) and link to the docs.

**Scope is limited to the two `.nix` files.** Do not propose changes to the dotfiles those configs reference (e.g., `config.fish`, `kitty.conf`, `tmux.conf`, `ranger/rc.conf`, `mpv/`, `espanso/`, `bat/config`). Even if a `programs.<name>` module could absorb one of those files, that is out of scope for this audit — the user wants a separate, larger decision before going down that path.

## Files to audit

- `~/dev/dotfiles/home.nix` — Linux config
- `~/dev/dotfiles/home-mac.nix` — macOS config (active on this machine; Darwin)

The two files mirror each other heavily but diverge in OS-specific bits (e.g., `xclip` only on Linux; `credential.helper = "osxkeychain"` vs `"libsecret"`; awesome/i3/regolith bits Linux-only). Treat divergences as intentional unless clearly accidental.

## Primary references — authority hierarchy

1. **Gold standard:** <https://nix-community.github.io/home-manager/options.xhtml> — the official options page. Every recommendation in the report MUST cite a specific option from this page (e.g., `programs.bat.enable`, `programs.fish.shellAliases`).

2. **Local verification (highest authority when it conflicts with the docs page):** the live option tree from the user's pinned home-manager channel. The docs page may describe a different channel than what's installed. Query the live tree like this:

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

   This catches deprecations like `programs.jujutsu.enableFishIntegration` (removed once shell integration became automatic) that won't be visible from just reading the docs page.

3. **Out of bounds:** memory of what home-manager options used to exist, blog posts, gists. Always verify against (1) and (2).

## Audit criteria

Run each check across both files. For each finding, record: file + line range, current code, recommended replacement, cited option(s), risk/breaking-change notes, and parity considerations between the two files.

### Check 1 — `pkgs.X` in `home.packages` with a `programs.X` module available

For every package in the `home.packages` list, check whether home-manager exposes a `programs.<name>` module. Examples worth verifying include (but the agent should not stop at this list): `bat`, `eza`, `fzf`, `gh`, `htop`, `jq`, `neovim`, `ranger`, `ripgrep`, `tmux`, `yt-dlp`, `fish`, `starship` (already enabled — confirm), `git` (already enabled — confirm), `delta` (already enabled — confirm), `nodejs`, `prettier`, `tree`.

For each match, judge whether switching to `programs.X.enable = true` (and possibly `.settings` / `.shellAliases` / `.enableFishIntegration` etc.) is an idiomaticity win. Reasons it often is:

- Declarative config supersedes hand-written rc files.
- Built-in shell-integration toggles wire fish/bash/zsh completions automatically.
- Cross-program integration toggles exist (e.g., `programs.delta.enableGitIntegration`, `programs.delta.enableJujutsuIntegration`).
- The package is installed by the module — keeping it in `home.packages` becomes redundant.

Reasons it might NOT be a win — call these out:

- The user has a hand-written config file in scope that this audit explicitly does not touch (per the scope rule above). In that case, flag the candidate but mark it deferred-pending-scope-expansion.
- The module's surface is much narrower than what the user actually uses.

### Check 2 — Deprecated, renamed, or removed options

Verify every currently-set option still exists in the user's channel. Examples of the kind of churn to watch for:

- Options that moved from `programs.<name>.extraConfig` to `programs.<name>.settings`.
- Integration toggles that became automatic (and now produce assertion errors if set).
- Renamed module attributes.

Flag any current option that the live option tree no longer recognizes, or that the docs page marks deprecated.

### Check 3 — Shell integration toggles

The user runs fish (see `pkgs.fish` and `home.file.".config/fish/config.fish"`). For each `programs.<name>` module that is or could be enabled, check whether an `enableFishIntegration` toggle exists and whether it's currently set. Note: some modules have removed the toggle because integration is now automatic — verify per Check 2 before recommending.

### Check 4 — Cross-program integration toggles

Look for opportunities where one program's module can wire itself into another. Existing examples in the codebase: `programs.delta.enableGitIntegration = true`. Other candidates worth checking against the docs:

- `programs.delta.enableJujutsuIntegration` (if jujutsu becomes managed).
- `programs.fzf.enableFishIntegration` and integration with `programs.fish`.
- `programs.gh` ↔ `programs.git` credential helper wiring.
- Anything else surfaced by reading the options page.

### Check 5 — `home.file` entries that a `programs.<name>` module would generate

For every `home.file.".config/<X>"` (or `.text = "…"`) entry, check whether a `programs.<X>` module exists that would generate the same file from declarative settings. Per the scope rule, the recommendation here is to **flag** these as candidates for a future, larger refactor — do not propose absorbing the file content into Nix in this audit.

Specific entries currently in the files (non-exhaustive list to verify): `.config/fish/config.fish`, `.config/kitty/kitty.conf`, `.config/ranger/rc.conf`, `.config/mpv/`, `.config/espanso/`, `.tmux.conf`, `.config/nvim/init.vim`, `.config/bat/config`, `.bashrc`, `.vimrc`.

### Check 6 — Cross-file parity (DRY)

The two files duplicate ~80%+ of their content. Consider whether the report should flag opportunities to factor common content into a shared module (`common.nix` or similar) that both `home.nix` and `home-mac.nix` import. List concretely which sections are identical, which differ for good reason (Linux-only WM bits, mac-only keychain), and which differ accidentally.

This is a structural recommendation, not a per-option one — call it out separately at the end of the report.

### Check 7 — Misc idiomaticity heuristics

- `home.sessionVariables` for env vars (already used for `LESS`) — anything else hard-coded into shell rc files that belongs here?
- `home.stateVersion` consistency.
- `extraOutputsToInstall = [ "man" ]` placement — is `programs.man.enable = true` (currently set) doing what the user expects in tandem?
- Use of `let dotfiles = …` — fine, but check if any references could move to `programs.<name>.settings` and drop the path entirely.

## Output format

Produce a markdown report with this shape:

```
# home-manager idiomaticity audit — YYYY-MM-DD

## Summary
- N findings, ranked by impact (High / Medium / Low).
- M deprecation issues found (these should be addressed even if no other changes are accepted).
- Cross-file parity assessment: <one line>.

## Findings

### [HIGH] <short title>
- **File(s):** home-mac.nix:L23, home.nix:L24
- **Current:** <minimal code excerpt>
- **Recommended:** <minimal code excerpt>
- **Home-manager option(s):** `programs.bat.enable`, `programs.bat.config` — <https://nix-community.github.io/home-manager/options.xhtml#opt-programs.bat.enable>
- **Why:** <one or two sentences>
- **Risk:** <one sentence — what could break, what to verify>
- **Parity note:** <does this apply to both files or just one?>

### [MEDIUM] …

…

## Cross-file parity (Check 6)
<concrete recommendation or "no action recommended">

## Deferred candidates (scope-limited)
<list of `home.file` entries that have `programs.<name>` modules but are deferred pending a separate scope decision>
```

Rank impact roughly as:

- **High** — fixes a deprecation, removes redundancy that's already causing or about to cause a runtime issue, or unlocks meaningful cross-program integration.
- **Medium** — clear idiomaticity win, no behavior change.
- **Low** — stylistic, micro-optimization, or aesthetic.

Cap the report at ~30 findings unless something compelling pushes past that.

## Constraints / non-goals

- **Do not edit files.** This is a read-only audit. The user explicitly chose report-only mode.
- **Do not run `home-manager switch`.** A `nix-instantiate --eval` to verify option existence is fine; full builds are not.
- **Do not propose changes to dotfiles outside the two `.nix` files** (e.g., editing `config.fish`, `kitty.conf`). Even if a `programs.<name>` module could absorb them, defer those — see Check 5.
- **Do not invent options.** Every cited option must appear in the docs page AND in the local option tree. If the two disagree, trust local and flag the discrepancy.
- **Do not touch the vimrc tangling flow.** `~/dev/dotfiles/vimrc.org` → `.vimrc` via org-babel is outside the audit surface.

## Background context the agent should load

- Memory: `~/.claude/projects/-Users-zyst/memory/user_dotfiles.md` — the dotfiles + home-manager flow, special cases (vimrc tangling, the `~/.config/home-manager/home.nix` symlink). Read this before starting.
- Memory: `~/.claude/projects/-Users-zyst/memory/reference_home_manager_options.md` — the docs URL and the verification methodology mirrored above.
- The user's git config currently uses SSH for github (`gh auth status` shows `Git operations protocol: ssh`), so HTTPS credential-helper wiring is forward-looking rather than load-bearing — relevant if the audit touches credential settings.
- `home-mac.nix` is the file currently linked from `~/.config/home-manager/home.nix` (symlink, set up 2026-05-13). Changes there are what would actually run on this machine.

## Verification the report is good

Before finalizing, the agent should self-check:

1. Every cited option name was verified via the live option tree, not just the docs page.
2. No finding proposes editing a file outside the two `.nix` files.
3. Deprecations are surfaced even if nothing else is recommended.
4. Each finding includes the parity note (does it apply to one file or both?).
5. The cross-file parity section is present even if the recommendation is "no action".
