#
# Tmux configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[tmux] )); then
  return 1
fi

# XDG path for tmux server sockets.
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"

# Path to the root tmux config file.
# Using this will bypass the system-wide configuration file, if any.
# NOTE: This is set in the login runcom so that the path is available for
# tmux commands invoked with run-shell and e.g. 'sh -c'.
export TMUX_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/main.tmux"
