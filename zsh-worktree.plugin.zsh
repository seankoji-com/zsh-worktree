# zsh-worktree — jump between the git worktrees of the current repository.
#
# `git worktree list` tells you where they are; this turns that into a picker
# and cd's to what you choose. With fzf it is a fuzzy list with a log preview,
# without it a numbered menu.
#
# Configure before loading:
#   ZSH_WORKTREE_PREVIEW   fzf preview command, {} is the worktree path.
#                          Set to '' to disable the preview.

: ${ZSH_WORKTREE_PREVIEW='git -C {} log --oneline -5 2>/dev/null'}

# List worktree paths, one per line. Public so it can be reused.
worktree_list() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
  command git worktree list --porcelain 2>/dev/null | awk '/^worktree /{print substr($0, 10)}'
}

wtree() {
  local -a dirs
  dirs=("${(@f)$(worktree_list)}") || {
    print -u2 "wtree: not inside a git repository"
    return 1
  }

  # ${(@f)$(...)} on empty output yields a one-element array holding an empty
  # string, not an empty array, so the count alone is not enough.
  (( ${#dirs} )) && [[ -n "$dirs[1]" ]] || {
    print -u2 "wtree: no worktrees found"
    return 1
  }

  local dir
  if (( ${#dirs} == 1 )); then
    dir=$dirs[1]
  elif (( $+commands[fzf] )); then
    local -a fzf_args
    fzf_args=(--prompt='worktree ❯ ' --height=40% --reverse)
    [[ -n "$ZSH_WORKTREE_PREVIEW" ]] && fzf_args+=(--preview="$ZSH_WORKTREE_PREVIEW")
    dir=$(print -l -- $dirs | fzf $fzf_args) || return
  else
    PS3='worktree ❯ '
    select dir in $dirs; do [[ -n "$dir" ]] && break; done
  fi

  [[ -n "$dir" ]] || return 1
  builtin cd -- "$dir"
}
