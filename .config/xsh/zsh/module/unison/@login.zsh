#
# Unison configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[unison] )) {
  return 1
}

# XDG path for the unison data directory.
export UNISON="$XDG_DATA_HOME/unison"
