#
# Trash configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[trash] )); then
  return 1
fi

# Remove files that have been trashed more than 30 days ago.
trash-empty -f 30
