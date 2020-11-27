#
# Main tmux configuration file.
#
# This configuration expects that the following environments variables are available:
# - TMUX_TERM         The default-terminal setting for tmux.
# - TMUX_HISTORY      The path to the history file for tmux commands.
# - TMUX_CLIPBOARD    The command to copy a buffer to the system clipboard.
# - TMUX_COMMAND_DIR  The path to a directory of custom commands to load as tmux aliases.
# - TMUX_CONFIG_DIR   The path to the parent directory to source other configuration files.
#

#
# Server options
#

# Set the correct TERM.
set -s default-terminal "$TMUX_TERM"

# Enable true color.
set -ga terminal-overrides ",xterm-256color:Tc"

# Faster command sequences. Over a slow network this might need to be increased.
set -s escape-time 10

# Do not pass focus events through to applications.
# This is disabled for emacs in particular, where it echoes '719476737;719476736' in the buffer
# on focus-in. I could not find any reference to this issue, and the terminal-focus-reporting emacs
# package did not help.
set -s focus-events off

# Path to the history file for tmux commands.
set -s history-file "$TMUX_HISTORY"

#
# Global session/window options
#

# Use regular interactive shells instead of login shells.
# This is a rather contextual choice.
# See https://superuser.com/questions/968942/why-does-tmux-create-new-windows-as-login-shells-by-default
#     http://openbsd-archive.7691.n7.nabble.com/tmux-and-login-shells-td170948.html
set -g default-command "exec /bin/zsh"

# The default command to pipe to in copy-mode.
set -g copy-command "$TMUX_CLIPBOARD"

# Switch to the most recently active session when the current session is destroyed.
set -g detach-on-destroy off

# Start window/pane indexes from 1 instead of 0.
set -g base-index 1
set -g pane-base-index 1

# When a window is closed, automatically renumber the other windows in numerical order.
set -g renumber-windows on

# Time in milliseconds the status messages are shown.
set -g display-time 2000
# Time in millisecond the pane numbers are shown and allowed to be selected.
set -g display-panes-time 1000

# Maximum number of lines held in window/pane history.
set -g history-limit 100000

# Time in milliseconds to allow multiple commands to be entered without the prefix-key.
set -g repeat-time 600

# Monitor windows for activity by default.
set -g monitor-activity on

# Notify of activity/silence in other windows only.
set -g activity-action other
set -g silence-action other
# Disable all bells.
set -g bell-action none

# Send a bell on activity.
set -g visual-activity off
# Display a status message instead of a bell on silence.
set -g visual-silence on

# Word separators for the copy-mode.
set -g word-separators " ._-~=+:;?!@&*()[]{}|<>/"

#
# Extra commands
#

# Import all command aliases from the command directory.
run '
  export TMUX_COMMAND_LOAD=100;
  for cmd in "$TMUX_COMMAND_DIR"/*; do \
    "$cmd";
    TMUX_COMMAND_LOAD=$(( TMUX_COMMAND_LOAD + 10 ));
  done
'

#
# Configuration modules
#

source "$TMUX_CONFIG_DIR/theme.tmux"
source "$TMUX_CONFIG_DIR/bindings.tmux"
source "$TMUX_CONFIG_DIR/plugins.tmux"
