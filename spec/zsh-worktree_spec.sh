# shellcheck shell=bash disable=all
# wtree uses zsh-only syntax (${(@f)} splitting, $+commands), which is why this
# suite runs under shellspec's zsh mode rather than bats.
Describe 'zsh-worktree.plugin.zsh'
  Include ./zsh-worktree.plugin.zsh

  # Restrict PATH so a real fzf on the developer's machine cannot leak into a
  # test that did not ask for one.
  BASE_PATH="/usr/bin:/bin"

  # pwd -P: on macOS mktemp hands back a path under /var, which is a symlink to
  # /private/var. git resolves it, so an unresolved TMPROOT never compares equal.
  setup() { TMPROOT="$(builtin cd "$(mktemp -d)" && pwd -P)"; PATH="$BASE_PATH"; hash -r; }
  cleanup() { rm -rf "$TMPROOT"; builtin cd "$SHELLSPEC_PROJECT_ROOT"; }
  BeforeEach 'setup'
  AfterEach 'cleanup'

  fake_fzf() {
    # $1: the line fzf should "select".
    mkdir -p "$TMPROOT/bin"
    cat > "$TMPROOT/bin/fzf" <<EOF
#!/bin/sh
cat >/dev/null
echo "$1"
EOF
    chmod +x "$TMPROOT/bin/fzf"
    PATH="$TMPROOT/bin:$BASE_PATH"
    hash -r
  }

  fake_fzf_cancel() {
    mkdir -p "$TMPROOT/bin"
    printf '#!/bin/sh\ncat >/dev/null\nexit 130\n' > "$TMPROOT/bin/fzf"
    chmod +x "$TMPROOT/bin/fzf"
    PATH="$TMPROOT/bin:$BASE_PATH"
    hash -r
  }

  Describe 'worktree_list'
    It 'fails outside a git repository'
      run_it() { builtin cd "$TMPROOT"; worktree_list; }
      When call run_it
      The status should be failure
    End

    It 'lists the main checkout'
      run_it() {
        mkdir -p "$TMPROOT/repo" && builtin cd "$TMPROOT/repo"
        git init -q
        worktree_list
      }
      When call run_it
      The output should include "$TMPROOT/repo"
    End

    # The obvious `awk '{print $2}'` truncates any worktree path containing a
    # space, which on macOS is not hypothetical.
    It 'handles a worktree path containing spaces'
      run_it() {
        mkdir -p "$TMPROOT/my repo" && builtin cd "$TMPROOT/my repo"
        git init -q
        worktree_list
      }
      When call run_it
      The output should include "$TMPROOT/my repo"
    End
  End

  Describe 'wtree'
    It 'errors outside a git repository'
      run_it() { builtin cd "$TMPROOT"; wtree; }
      When call run_it
      The status should be failure
      The stderr should include 'not inside a git repository'
    End

    It 'cds straight there when there is only one worktree'
      run_it() {
        mkdir -p "$TMPROOT/repo" && builtin cd "$TMPROOT/repo"
        git init -q
        mkdir -p sub && builtin cd sub
        wtree
        print -r -- "$PWD"
      }
      When call run_it
      The output should equal "$TMPROOT/repo"
    End

    It 'cds to the worktree fzf selected'
      run_it() {
        mkdir -p "$TMPROOT/repo" && builtin cd "$TMPROOT/repo"
        git init -q
        git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
        git worktree add -q "$TMPROOT/wt-feature" -b feature
        fake_fzf "$TMPROOT/wt-feature"
        wtree
        print -r -- "$PWD"
      }
      When call run_it
      The output should equal "$TMPROOT/wt-feature"
    End

    It 'stays put when the picker is cancelled'
      run_it() {
        mkdir -p "$TMPROOT/repo" && builtin cd "$TMPROOT/repo"
        git init -q
        git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
        git worktree add -q "$TMPROOT/wt-feature" -b feature
        fake_fzf_cancel
        # Capture wtree's own status: run_it would otherwise report the status
        # of the trailing print, which is always 0.
        wtree; local rc=$?
        print -r -- "$PWD"
        return $rc
      }
      When call run_it
      The output should equal "$TMPROOT/repo"
      The status should be failure
    End
  End
End
