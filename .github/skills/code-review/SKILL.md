---
name: code-review
description: Review priorities for zsh-worktree pull requests, what deserves real scrutiny versus what to skip. Use for every PR review.
---

# Review priorities

zsh-worktree is a single-purpose plugin: two functions in one ~40-line file. Nearly all review value is in that file; the last five PRs were CI-template syncs and a docs add, none of which touched it.

## Spend real attention here
- `zsh-worktree.plugin.zsh` — this file is the entire plugin. Any change to it is the review.
- `worktree_list`'s awk parse of `git worktree list --porcelain`, and the `${(@f)$(...)}` empty-output handling in `wtree` (both carry gotcha comments in the source). A parsing change here risks silently mis-splitting a worktree path.
- Path/quoting hygiene generally: the one recurring real hazard in this codebase is an unquoted or word-split path. `spec/zsh-worktree_spec.sh` calls a worktree path with a space "not hypothetical" on macOS — treat any new path variable with the same suspicion.
- The `fzf` vs `select` fallback branch and the fzf-cancelled (exit 130) path in `wtree` — interactive control flow that only the faked-fzf tests exercise; easy to regress unnoticed.
- When plugin logic changes, confirm `spec/zsh-worktree_spec.sh` grew a matching case rather than just re-asserting old behavior.

## Do not spend attention here
- `.github/workflows/*.yml` — synced from the org's central `seankoji-com/.github` template repo (three of the last five PRs are exactly this sync); review the upstream repo, not the copy here.
- `README.md`, `LICENSE`, `.gitignore` — docs and boilerplate, no logic.
- `.shellspec`, `spec/spec_helper.sh` — a couple of lines of test-framework config each, not logic.

## Comment style
- One comment per real issue, not one per file it repeats in.
- Skip restating what the `shellspec` CI job already runs and would catch.
