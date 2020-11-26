#
# Trash configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[trash] )) {
  return 1
}

# This is not recommended by the author:
# https://github.com/andreafrancia/trash-cli#can-i-alias-rm-to-trash-put
# alias rm='trash'

# Since `rm` is hard-wired into my fingers, this is a more intrusive approach.
# Hitting enter twice will trash, enter + y will permanently delete.
# Note that this approach also disables the trash when using `sudo`.
function rm {
  local bye
  print -n 'delete permanently? [y/N] ' && read -sq bye; print
  if [[ $bye == 'y' ]] {
    command rm -rv $@
  } else {
    trash $@
  }
}

# Short way to restore from trash.
# If the file to restore is not under the current directory, the desired
# parent directory can be specified.
function mr {
  (
    [[ $1 ]] && { cd "$1" || return }
    trash-restore 2>/dev/null
  )
}

# List trashed files.
alias rml='trash-list'

# Remove any previously defined alias including options such as -i/-I,
# which `trash` attempts to replace.
(( $+aliases[rm] )) && unalias rm
