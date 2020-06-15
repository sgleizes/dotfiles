#
# Unison configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[unison] )) {
  return 1
}

# Convenience aliases.
alias sync='unison'
alias sync-watch='unison -repeat watch'
alias sync-mirror='unison -force newer -times'
