#
# Unison configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[unison] )); then
  return 1
fi

# XDG path for the unison data directory.
export UNISON="$XDG_DATA_HOME/unison"
