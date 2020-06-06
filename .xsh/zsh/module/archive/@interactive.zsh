#
# Archive management module for zsh.
#

# Abort if requirements are not met.
if (( ! $+functions[zinit] )) {
  return 1
}

# Provide functions to create, list and extract archives.
# https://github.com/sorin-ionescu/prezto/blob/master/modules/archive/README.md
zinit ice wait'0b' lucid svn pick'/dev/null'
zinit snippet PZT::modules/archive

# Usability aliases.
alias ac='archive'
alias al='lsarchive'
alias ax='unarchive'

# Color the contents of tar archives using LS_COLORS.
zinit ice wait'0b' lucid depth=1 fbin'bin/tarcolor' nocompile
zinit light msabramo/tarcolor

# Better implementation of tarcolorauto.
function tar {
  if [[ -t 1 && $1 == *tv* ]] {
    command tar $@ | tarcolor
  } else {
    command tar $@
  }
}
