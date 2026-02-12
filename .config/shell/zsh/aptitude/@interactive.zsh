#
# Aptitude configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Abort if requirements are not met.
if (( ! $+commands[apt] )); then
  return 1
fi

#
# Basic aliases
#

alias sapt='sudo apt'                # faster
