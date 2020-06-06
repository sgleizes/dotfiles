#!/bin/zsh
#
# Reload the tmux configuration.
#

# Define the alias for this command.
if [[ $TMUX_COMMAND_LOAD ]] {
  tmux set "command-alias[$TMUX_COMMAND_LOAD]" reload="run '$0'"
  return
}

tmux source "$TMUX_CONFIG" && tmux display "sourced $TMUX_CONFIG"
