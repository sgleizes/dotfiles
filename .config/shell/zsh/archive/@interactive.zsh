#
# Archive management module for zsh.
#

# Use atool if available.
if (( $+commands[atool] )); then
  # Usability aliases.
  alias ac='apack 2>/dev/null'
  alias al='als 2>/dev/null'
  alias ax='aunpack 2>/dev/null'

  alternative='atool'
fi

# Abort if requirements are not met.
if (( ! $+functions[zi] )); then
  return 1
fi

if [[ ! "$alternative" ]]; then
  # Provide functions to create, list and extract archives.
  # https://github.com/sorin-ionescu/prezto/blob/master/modules/archive/README.md
  zi ice wait'0b' lucid svn pick'/dev/null'
  zi snippet PZT::modules/archive

  # Usability aliases.
  alias ac='archive'
  alias al='lsarchive'
  alias ax='unarchive'
fi

# Color the contents of tar archives using LS_COLORS.
zi ice wait'0b' lucid depth=1 fbin'bin/tarcolor' nocompile
zi light msabramo/tarcolor

# Better implementation of tarcolorauto.
function tar {
  if [[ -t 1 && $1 == *tv* ]]; then
    command tar $@ | tarcolor
  else
    command tar $@
  fi
}

unset alternative
