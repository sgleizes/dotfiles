#
# Trash configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[trash] )) {
  return 1
}

# Remove files that have been trashed more than 30 days ago.
trash-empty 30
