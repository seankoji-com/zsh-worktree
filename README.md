# zsh-worktree

Jump between the git worktrees of the current repository.

`wtree` reads the worktrees of the current repository from `git worktree list`, lets you pick one, and `cd`s into it. If [fzf](https://github.com/junegunn/fzf) is installed you get a fuzzy list with a git-log preview of each worktree; otherwise it falls back to a numbered `select` menu. When there is only a single worktree it switches to it without prompting. The preview command is configurable.

## Installation

### Manual

Clone the repo and source the plugin from your `.zshrc`:

```zsh
git clone https://github.com/seankoji-com/zsh-worktree ~/.zsh/zsh-worktree
echo 'source ~/.zsh/zsh-worktree/zsh-worktree.plugin.zsh' >> ~/.zshrc
```

### zinit

```zsh
zinit light seankoji-com/zsh-worktree
```

### oh-my-zsh

Clone into your custom plugins directory:

```zsh
git clone https://github.com/seankoji-com/zsh-worktree \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-worktree
```

Then add it to the `plugins` array in your `.zshrc`:

```zsh
plugins=(... zsh-worktree)
```

[fzf](https://github.com/junegunn/fzf) is optional but recommended for the fuzzy picker and preview.

## Usage

From inside a git repository:

```zsh
wtree
```

Pick a worktree and you'll be `cd`'d into it. With a single worktree, `wtree` switches to it directly.

`worktree_list` is also exposed as a public helper that prints the worktree paths one per line, so you can reuse it in your own scripts.

### Configuration

Set before loading the plugin:

| Variable                | Default                                    | Description                                                    |
|-------------------------|--------------------------------------------|----------------------------------------------------------------|
| `ZSH_WORKTREE_PREVIEW`  | `git -C {} log --oneline -5 2>/dev/null`   | fzf preview command; `{}` is the worktree path. Set to `''` to disable the preview. |

## License

MIT — see [LICENSE](LICENSE).
