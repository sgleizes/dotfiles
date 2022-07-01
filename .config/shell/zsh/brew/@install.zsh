#
# Brew installation module for zsh.
# This module installs dependencies of the CLI environment using homebrew.
#
# Usage: xsh load brew install
#

# Abort if requirements are not met.
if (( ! $+commands[brew] )); then
  return 1
fi

# TODO
