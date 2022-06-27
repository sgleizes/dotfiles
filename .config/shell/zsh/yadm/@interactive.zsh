#
# Yadm configuration module for zsh.
#
# NOTE: This module defines an additional git wrapper command and should be
# loaded before the git module.
# NOTE: Helper commands are provided as executable in ~/.local/bin/my.
#

# Abort if requirements are not met.
if (( ! $+commands[yadm] )); then
  return 1
fi

# Register yadm as a git wrapper command, see the git module.
_git_wrapper_commands+=(yadm)

# Add function dir to fpath.
autoload_dir ${0:h}/function
