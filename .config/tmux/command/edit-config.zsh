#!/bin/zsh
#
# Edit the tmux configuration.
#

# Define the alias for this command.
if [[ $TMUX_COMMAND_LOAD ]] {
  tmux set "command-alias[$TMUX_COMMAND_LOAD]" edit-config="run '$0'"
  return
}

tmux popup -w90% -h90% -E -d '#{pane_current_path}' \
  "${VISUAL:-${EDITOR}} $TMUX_CONFIG && tmux reload"
