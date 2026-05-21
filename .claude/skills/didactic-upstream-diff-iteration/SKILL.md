---
name: didactic-upstream-diff-iteration
description: Review a batch of candidate changes (typically from a diff against an upstream source) one at a time. For each candidate present upstream vs. local, ask adopt/decline, on adopt apply minimally + give concrete test steps + wait for confirmation, on decline back out and record the rejection so it won't be re-suggested. Use for upstream-config audits, large dependency upgrades, opt-in feature batches.
---

# Didactic upstream-diff iteration

A procedure for reviewing a queue of candidate changes one at a time, with a confirm-or-back-out loop per candidate and a persistent rejection record so declined items aren't re-suggested on later runs.

The skill is **just the procedure**. The caller (a domain-specific agent prompt, or a human request) supplies the candidates, the rejection-list path, and the reload recipe.

## When to invoke

- An audit report enumerates many small findings the user wants to triage individually.
- A diff against an upstream source surfaces a batch of patterns the user might adopt.
- A plugin / dependency upgrade ships a list of opt-in features.
- The user explicitly says "go through these one at a time" or has queued more than 2 candidate adoptions.

If the user wants a single change applied immediately, this skill is overkill — just make the change.

## Inputs the caller must supply

1. **Pending-candidates source** — a file the caller owns (e.g. the "Pending candidates" section of an agent prompt). Entries can be removed as they resolve.
2. **Rejected-list path** — by convention a sibling file named `rejected.md` next to the candidates source. Read it before each candidate; append to it on decline/back-out.
3. **Domain-specific reload recipe** — the exact command sequence to make an adopted change take effect, plus the keystrokes / commands needed to exercise the new behavior. Examples:
   - tmux: `home-manager switch && tmux source-file ~/.tmux.conf` (live reload), or detach + re-attach if state matters.
   - nvim: edit `vimrc.org` → re-tangle → `home-manager switch`; if a plugin's branch/version changed, also `rm -rf ~/.config/nvim/plugged/<plugin>` + `:PlugInstall`.
   - home-manager option: `home-manager switch` + the verification command for that option (e.g. `nix-instantiate --eval -E '...'`).

## The loop (per candidate)

1. **Read pending candidates** from the caller's source.
2. **Read the rejected-list.** If the upstream snippet matches an existing rejected entry, skip silently and move to the next candidate. If the upstream form has materially changed since rejection, surface it as a new candidate with a one-line note about the prior rejection.
3. **Present a single candidate** with three fields:
   - **Upstream / proposed:** the relevant snippet (with file/line citation if available).
   - **Current:** the corresponding local snippet, or "absent" if the pattern isn't present locally.
   - **Why it might be worth adopting:** 1–3 sentences.
4. **Ask via `AskUserQuestion`:** `Adopt` / `Decline` / `Skip for now`.
5. **On Adopt:**
   - Make the minimal edits to apply the candidate.
   - Report exactly which files changed.
   - Output the reload recipe + the specific keystrokes / commands the user should run to exercise the new behavior.
   - **Ask via `AskUserQuestion`:** `Confirmed working — keep` / `Not what I wanted — back out`.
   - On **keep**: delete the candidate's entry from the pending source.
   - On **back-out**: revert the edits, re-output the reload steps, then fall through to the Decline branch below.
6. **On Decline (or back-out from Adopt):**
   - Append a record to the rejected-list with the fingerprint shape the caller's prompt documents (typically: short title, date, upstream source URL + line range or commit, upstream snippet, one-line reason, re-evaluate trigger).
   - Delete the entry from the pending source.
7. **On Skip for now:** leave the entry in place; move to the next candidate.

## Idempotency and safety rules

- **One candidate per turn.** Never present a list of two or more candidates in the same turn.
- **No batched adoptions.** Each adoption gets its own confirm-keep / back-out cycle before moving on.
- **Always read the rejected-list before presenting a candidate.** If unsure whether a snippet has "materially changed" since rejection, treat it as still-rejected (skip silently) — the user can always re-introduce it manually.
- **Never push, commit, or run system-mutating commands** (`home-manager switch`, package installs, etc.) on the user's behalf as part of the loop — output them as recipes for the user to run.

## Stop conditions

- The pending source is empty.
- The user says stop / pause / "we'll come back to this."

When stopping mid-queue, leave the pending source as-is; resuming later picks up from the first unresolved entry.

## Anchor

This skill is the procedure only. The caller's domain-specific prompt (e.g. `.claude/agents/tmux-upstream-audit/agent-prompt.md` in the dotfiles repo) supplies the actual candidates, the upstream source URL, the rejected-list path, and the reload recipe.
