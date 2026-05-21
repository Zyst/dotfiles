# tmux upstream audit — rejected candidates

This file is read **before** generating candidates in the tmux upstream audit. Any upstream pattern whose snippet matches an entry below is skipped silently on subsequent runs (unless the upstream form has materially changed since the rejection — then it surfaces as a new candidate with an inline note about the prior rejection).

See `./agent-prompt.md` for the audit prompt that owns this file.

## Entry template

```markdown
## <short title>

- **Date:** YYYY-MM-DD
- **Upstream source:** <url + line range or commit if known>
- **Upstream snippet:**
  ```tmux
  <enough to fingerprint>
  ```
- **Reason:** <one line from the user, or "declined after testing">
- **Re-evaluate if:** <e.g. "upstream snippet changes" — default rule>
```

## Entries

_(none yet)_
