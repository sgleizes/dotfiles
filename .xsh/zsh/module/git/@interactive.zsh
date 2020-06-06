#
# Git configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Abort if requirements are not met.
if (( ! $+commands[git] )) {
  return 1
}

# Autoload all module functions.
autoload_dir ${0:h}/function

# NOTE: Loads of possible aliases, cherry pick as needed from:
# https://github.com/sorin-ionescu/prezto/blob/master/modules/git/alias.zsh
alias g='git'

# Branch (b)
alias gb='git branch'
alias gba='git branch --all'
alias gbl='git branch --verbose'
alias gbL='git branch --verbose --all'
alias gbc='git checkout -b'
alias gbs='git show-branch'
alias gbS='git show-branch --all'
alias gbx='git branch --delete'
alias gbX='git branch --delete --force'

# Commit (c)
alias gc='git commit'
alias gca='git commit --all'
alias gcm='git commit --message'
alias gcam='git commit --all --message'
alias gco='git checkout'
alias gcr='git revert'
alias gcR='git reset "HEAD^"'
alias gcs='git show'
alias gcl='git-commit-lost' # assuming defined function
alias gcp='git cherry-pick --ff'
alias gcP='git cherry-pick --no-commit'

# Fetch (f)
alias gf='git fetch'
alias gfa='git fetch --all'
alias gfc='git clone'
alias gfm='git pull'
alias gfr='git pull --rebase'

# Remote (R)
alias gR='git remote --verbose'

# Index (i)
alias gia='git add'
alias giA='git add --patch'
alias giu='git add --update'
alias gid='git diff --cached'
alias giD='git diff --cached --word-diff'
alias gii='git update-index --assume-unchanged'
alias giI='git update-index --no-assume-unchanged'
alias gir='git reset'
alias giR='git reset --patch'
alias gix='git rm -r --cached'
alias giX='git rm -rf --cached'

# Log (l)
alias gl='git log --topo-order'
alias gls='git log --topo-order --stat'
alias gld='git log --topo-order --stat --patch --full-diff'
alias glS='git log --topo-order --show-signature'
alias glo='git log --topo-order --pretty=brief' # assuming pretty.brief is defined
alias glg='git log --topo-order --pretty=brief --all --graph'
alias glc='git shortlog --summary --numbered'
alias glr='git review' # assuming alias.review is defined

# Merge (m)
alias gm='git merge'
alias gmt='git mergetool'

# Push (p)
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpF='git push --force'
alias gpa='git push --all'
alias gpA='git push --all && git push --tags'
alias gpt='git push --tags'
alias gpc='git push --set-upstream origin "$(git-branch-current 2>/dev/null)"'
alias gpp='git pull origin "$(git-branch-current 2>/dev/null)" && git push origin "$(git-branch-current 2>/dev/null)"'

# Rebase (r)
alias gr='git rebase'
alias gri='git rebase --interactive'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias grs='git rebase --skip'

# Stash (s)
alias gs='git stash'
alias gsk='git stash push --keep-index'
alias gss='git stash push --include-untracked'
alias gsS='git stash push --patch --no-keep-index'
alias gsd='git stash show --patch --stat'
alias gsl='git stash list'
alias gsL='git-stash-dropped' # assuming defined function
alias gsa='git stash apply'
alias gsp='git stash pop'
alias gsr='git-stash-recover' # assuming defined function
alias gsx='git stash drop'
alias gsX='git-stash-clear-interactive' # assuming defined function

# Tag (t)
alias gt='git tag'
alias gtl='git tag --list'
alias gtv='git verify-tag'

# Working Copy (w)
alias gws='git status'
alias gwS='git status --no-short' # assuming status.short is true
alias gwd='git diff'
alias gwD='git diff --word-diff'
alias gwr='git reset --soft'
alias gwR='git reset --hard'
alias gwc='git clean -n'
alias gwC='git clean -f'
alias gwx='git rm -r'
alias gwX='git rm -rf'

# Support for https://github.com/github/hub.
if (( $+commands[hub] )) {
  # Extension for run-help to support 'hub' subcommands.
  function run-help-hub {
    if (( $# == 0 ))  {
      man hub
    } else {
      man hub-$1
    }
  }

  # Update the git user-commands style for hub completion.
  # This allows user-defined commands to show up in completion when using 'hub'.
  function _update_hub_user_commands {
    local user_commands
    zstyle -a ':completion:*:*:git:*' user-commands user_commands
    zstyle ':completion:*:*:hub:*' user-commands $user_commands
  }
  _update_hub_user_commands

  # Explicit equivalent of `eval "$(hub alias -s)"`.
  alias git='hub'
}

# Support for https://github.com/jesseduffield/lazygit.
if (( $+commands[lazygit] )) {
  # Change working directory to the repo in use when exiting lazygit.
  function lazygit {
    export LAZYGIT_NEW_DIR_FILE="$TMPDIR/lazygit-newdir"

    command lazygit "$@"
    if [[ -f $LAZYGIT_NEW_DIR_FILE ]]; then
      cd "$(<$LAZYGIT_NEW_DIR_FILE)"
      command rm -f $LAZYGIT_NEW_DIR_FILE >/dev/null
    fi
  }

  # Lazier git.
  alias lg='lazygit'

  # Laziest git.
  zle -N open-lazygit lazygit
  bindkey "$keys[Control]O$keys[Control]G" open-lazygit
}

# Support for https://github.com/dandavison/delta.
if (( $+commands[delta] )) {
  function delta {
    if (( $# > 0 )) {
      command delta "$@"
      return
    }

    # Default options for delta.
    # NOTE: There is currently no way to set a default config, so this is duplicated
    # in the git and lazygit configuration files for now.
    command delta \
      --tabs 2 --theme='OneHalfDark' \
      --commit-style=box --commit-color=247 \
      --file-style=box --file-color=12 --hunk-color=12 \
      --plus-color=22 --plus-emph-color=28 \
      --minus-color=52 --minus-emph-color=88 \
      --keep-plus-minus-markers
  }
}

# Abort if requirements are not met.
if (( ! $+functions[zinit] )) {
  return 2
}

# Git entrypoint that wraps commands and deals with conflicts.
# This also works if 'hub' is aliased to 'git'.
function git hub {
  case $1 in
    # Wrap the git clone command to prettify output.
    clone)
      command "$0" clone --progress "${@:2}" \
        |& { $ZINIT[BIN_DIR]/git-process-output.zsh || cat; } 2>/dev/null ;;
    # Bypass hub commands that conflict with better 'git-extras' commands.
    # The following conflicting commands are not bypassed: fork, pr, pull-request, sync, release.
    alias)
      command git "$@" ;;
    # Make available 'git-extras' commands which are not entirely superseeded by 'hub' commands.
    # A git alias should be defined for these commands so that shell completion is enabled.
    make-release)
      command git release "${@:2}" ;;
    *)
      command "$0" "$@" ;;
  esac
}

# Load completions for git-extras.
# NOTE: These completions are not defined using `compdef`, they only extend
# the _git completion function that ships with zsh by using the user-commands style.
# Therefore, it does not have any loading order requirement.
if (( $+commands[git-extras] )) {
  zinit ice wait'0b' lucid id-as'tj/git-extras-completion' reset \
    atinit"sed -i '/_git-release()/,+8s/''$/'' \\\\/' git-extras-completion" \
    atload'(( $+functions[_update_hub_user_commands] )) && _update_hub_user_commands'
  zinit snippet "https://github.com/tj/git-extras/raw/$(git-extras -v)/etc/git-extras-completion.zsh"
}

# Automatically detect and escape zsh globbing meta-characters when used with
# git refspec characters like `[^~{}]`. NOTE: This must be loaded _after_
# url-quote-magic, which is the motivation for the zinit 'wait slot'.
zinit ice wait'0b' lucid depth=1 pick'git-escape-magic'
zinit light knu/zsh-git-escape-magic
