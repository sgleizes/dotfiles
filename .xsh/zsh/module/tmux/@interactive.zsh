#
# Tmux configuration module for zsh.
#
# NOTE: Since the autostart feature will replace the current shell by tmux,
# this module should be loaded first to avoid unecessary loading.
#

# Abort if requirements are not met.
if (( ! $+commands[tmux] )) {
  return 1
}

# Automatically start/attach to tmux. Possible values are:
# - local   enable when starting zsh in a local terminal.
# - remote  enable when starting zsh over a SSH connection.
# - always  both of the above.
# Set to any other value to disable.
: ${TMUX_AUTOSTART:=always}

# Define what to do when autostarting. Possible values are:
# - background      do not prompt and run a regular shell.
# - attach          do not prompt and attach to tmux.
# - prompt          prompt to attach or run a regular shell.
# - prompt-fortune  like prompt but display a fortune before the prompt.
# - prompy-pony     like prompt but display a fortune using ponysay before the prompt.
# Note that the tmux server is started in the background regardless of this option.
# This is useful to be properly welcomed to the terminal while the tmux session is
# being restored, e.g. with tmux-resurrect/continuum.
: ${TMUX_AUTOSTART_MODE:=prompt-pony}

# The name of the default created session if none are defined in the tmux config.
: ${TMUX_DEFAULT_SESSION:=main}

# NOTE: The parameters below are exported to be used from within the tmux config file.

# Figure out the TERM to use inside tmux.
(( $terminfo[colors] >= 256 )) \
  && export TMUX_TERM='tmux-256color' \
  || export TMUX_TERM='tmux'

# Path to the tmux command history.
export TMUX_HISTORY="$XDG_DATA_HOME/tmux/history"

# Copy command for clipboard integration.
export TMUX_CLIPBOARD='xclip -selection clipboard'

# Path to the directory for autoloaded tmux commands.
export TMUX_COMMAND_DIR="${TMUX_CONFIG:h}/command"

# Path to the tmux directory to source other configuration files.
export TMUX_CONFIG_DIR="${TMUX_CONFIG:h}"

# Create the XDG data directory if necessary.
command mkdir -p ${TMUX_HISTORY:h}

# Autostart tmux and attach to a session, if enabled and not already in tmux.
# Attempt to detect whether the terminal is started from within another application.
# In xterm (or terminals mimicking it), WINDOWID is set to 0 if the terminal is not
# running in a X window (e.g. in a KDE application).
if [[ ! $TMUX && ! $EMACS && ! $INSIDE_EMACS && $WINDOWID != 0 ]] && { \
  [[   $SSH_TTY && $TMUX_AUTOSTART == (always|remote) ]] ||
  [[ ! $SSH_TTY && $TMUX_AUTOSTART == (always|local) ]]
} {
  function {
    # Start the tmux server, this is only useful if a session is created in the tmux config.
    # Otherwise the server will exit immediately (unless exit-empty is turned off).
    tmux -f "$TMUX_CONFIG" start-server

    # Create the default session if no session has been defined in tmux.conf.
    if ! tmux has-session 2>/dev/null; then
      tmux -f "$TMUX_CONFIG" new-session -ds "$TMUX_DEFAULT_SESSION"
    fi

    # Perform the action defined by the selected autostart mode.
    local attach
    if [[ $TMUX_AUTOSTART_MODE == 'attach' ]] {
      attach=true
    } elif [[ $TMUX_AUTOSTART_MODE == prompt* ]] {
      # Convert the autostart mode to a fortune mode.
      local fortune_mode='none'
      case $TMUX_AUTOSTART_MODE in
        prompt-fortune) fortune_mode='basic' ;;
        prompt-pony) fortune_mode='pony' ;;
      esac

      # Display a fortune if requested.
      if [[ $fortune_mode != 'none' ]] {
        FORTUNE_LOGIN="$fortune_mode" FORTUNE_INTERACTIVE="$fortune_mode" xsh load fortune
        print
      }

      # Interactively ask to enter tmux or a regular shell.
      local ans
      print -n ':: Attach to tmux session? [y/n] ' && read -sk ans; echo
      [[ $ans == ('y'|$'\n') ]] && attach=true
    }

    # Attach to the default session or to the most recently used unattached session.
    [[ $attach ]] && exec tmux attach-session
  }
}

# Convenience aliases.
alias tmux="tmux -f '$TMUX_CONFIG'"
alias tx='tmux'
alias txa="tmux new-session -As '$TMUX_DEFAULT_SESSION'"

# Set the pane title to the current directory on every precmd.
function _tmux_set_pane_title { print -Pn '\033]2;%~\033\\'; }
typeset -ag precmd_functions
if [[ ! ${precmd_functions[(r)_tmux_set_pane_title]} ]] {
  precmd_functions+=( _tmux_set_pane_title )
}

# Enable starting fzf in a tmux popup.
(( $+commands[fzf] )) && export FZF_TMUX=1

# Integration with https://github.com/greymd/tmux-xpanes.
if (( $+commands[tmux-xpanes] )) {
  export TMUX_XPANES_LOG_DIRECTORY="$XDG_DATA_DIR/xpanes/"
  export TMUX_XPANES_LOG_FORMAT="[:ARG:].%Y-%m-%dT%H:%M:%S.log"

  # Use bash as the default shell for xpanes (performance).
  function xpanes {
    local cmd=$(tmux show -gv default-command)
    tmux set -g default-command "exec /bin/bash"
    command xpanes "$@"
    tmux set -g default-command "$cmd"
  }

  # Convenience aliases, see https://github.com/greymd/tmux-xpanes/wiki/Alias-examples.
  alias xp='xpanes'
  alias xpp='xpanes -B "set {}"'
  alias xpi='xpanes -B '\''INDEX=$(tmux display -pt "${TMUX_PANE}" "#{pane_index}")'\'''
}
