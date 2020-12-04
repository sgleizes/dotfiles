#
# Unison configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[unison] )); then
  return 1
fi

# Convenience aliases.
alias sync='unison'
alias sync-watch='unison -repeat watch'
alias sync-mirror='unison -force newer -times'
