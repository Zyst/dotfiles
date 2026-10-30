# tmux notes

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
