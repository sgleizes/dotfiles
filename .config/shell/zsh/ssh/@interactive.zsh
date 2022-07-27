#
# SSH configuration module for zsh.
#

# Return if requirements are not met.
if (( ! $+commands[ssh] )); then
  return 1
fi

# Prevent breaking SSH if the remote machine does not support xterm-24bit.
alias ssh='TERM=xterm-256color ssh'
