#
# Git configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Abort if requirements are not met.
if (( ! $+commands[git] )); then
  return 1
fi

# Autoload all module functions.
autoload_dir ${0:h}/function

# Main git alias, everything else is defined as git config aliases.
# This approach allows to reuse the aliases for tools wrapping git, e.g. yadm.
alias g='git'

# Support for https://github.com/github/hub.
if (( $+commands[hub] )); then
  # Extension for run-help to support 'hub' subcommands.
  function run-help-hub {
    if (( $# == 0 )) ; then
      man hub
    else
      man hub-$1
    fi
  }

  # Register hub as a git wrapper command, see below.
  _git_wrapper_commands+=(hub)

  # Explicit equivalent of `eval "$(hub alias -s)"`.
  alias git='hub'
fi

# Support for https://github.com/jesseduffield/lazygit.
if (( $+commands[lazygit] )); then
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
fi

# List all git wrapper commands and aliases.
function _list_git_wrappers {
  local -U git_commands=(git $_git_wrapper_commands)
  git_commands+=($(alias | grep -E "=(git|${(j:|:)_git_wrapper_commands})" | cut -d= -f1))
  print $git_commands[@]
}

# Update the git user-commands style for git wrappers.
# This allows user-defined commands to show up in completion when using git wrappers.
function _update_git_user_commands {
  local user_commands
  if [[ "$_git_wrapper_commands" ]]; then
    zstyle -a ':completion:*:*:git:*' user-commands user_commands
    zstyle -d ':completion:*:*:git:*' user-commands
    zstyle ":completion:*:*:(git|${(j:|:)_git_wrapper_commands}):*" user-commands $user_commands
  fi
  unfunction _update_git_user_commands
}

# Abort if requirements are not met.
if (( ! $+functions[zinit] )); then
  _update_git_user_commands
  return 2
fi

# Git entrypoint that wraps commands and deals with conflicts.
# This also works if 'hub' is aliased to 'git'.
function git $_git_wrapper_commands {
  case $1 in
    # Wrap the git clone command to prettify output.
    clone)
      command "$0" clone --progress "${@:2}" \
        |& { $ZINIT[BIN_DIR]/git-process-output.zsh || cat; } 2>/dev/null ;;
    # Wrap the git stash clear command for safety.
    stash)
      [[ "$2" == 'clear' ]] && { git-stash-clear-interactive; return }
      command "$0" "$@" ;;
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
if (( $+commands[git-extras] )); then
  zinit ice wait'0b' lucid id-as'tj/git-extras-completion' \
    atload'_update_git_user_commands'
  zinit snippet "https://github.com/tj/git-extras/raw/$(git-extras -v)/etc/git-extras-completion.zsh"
fi

# Automatically detect and escape zsh globbing meta-characters when used with
# git refspec characters like `[^~{}]`. NOTE: This must be loaded _after_
# url-quote-magic, which is the motivation for the zinit 'wait slot'.
# The plugin is patched to work with all defined git wrappers and aliases.
zinit ice wait'0b' lucid depth=1 reset \
  atclone'sed -i "s;(\*/|)git;(*/|)("${(j:|:)$(_list_git_wrappers)}");g" git-escape-magic' \
  atpull'%atclone' nocompile'!' \
  pick'git-escape-magic'
zinit light knu/zsh-git-escape-magic
