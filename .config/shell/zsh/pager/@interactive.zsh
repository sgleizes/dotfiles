#
# Pager configuration module for zsh.
#

# Return if requirements are not met.
if [[ $TERM == 'dumb' ]]; then
  return 1
fi

# Convenience aliases.
alias p='${(z)PAGER}'
alias more='less' # less is more or less more

# Set default less options.
export LESSHISTFILE="$XDG_DATA_HOME/less/history"
export LESSHISTSIZE=50
export LESS='-QRSMi -#.25 --no-histdups'
export SYSTEMD_LESS="$LESS"

# Set default colors for less.
export LESS_TERMCAP_mb=$'\E[01;31m'    # begins blinking
export LESS_TERMCAP_md=$'\E[01;34m'    # begins bold
export LESS_TERMCAP_me=$'\E[0m'        # ends mode
export LESS_TERMCAP_so=$'\E[00;47;30m' # begins standout-mode
export LESS_TERMCAP_se=$'\E[0m'        # ends standout-mode
export LESS_TERMCAP_us=$'\E[01;33m'    # begins underline
export LESS_TERMCAP_ue=$'\E[0m'        # ends underline

# Create the XDG data directory if necessary.
command mkdir -p ${LESSHISTFILE:h}

# Pager integration with bat.
if (( $+commands[bat] )); then
  export BAT_PAGER='less -F'
fi

# Use pistol as input preprocessor.
if (( $+commands[pistol] )); then
  export LESSOPEN='| pistol %s 2>&-'
fi
