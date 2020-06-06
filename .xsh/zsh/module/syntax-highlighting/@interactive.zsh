#
# Syntax highlighting configuration module for zsh.
#
# NOTE: This module should be loaded after all ZLE widgets have been defined.
# In general, that means after completion and ZLE settings.
#

# Abort if requirements are not met.
if [[ $TERM == 'dumb' || $+functions[zinit] == 0 ]] {
  return 1
}

# Syntax highlighting plugin with the default theme.
# Use `fast-theme` to configure.
zinit ice wait lucid depth=1 atload'unalias fsh-alias'
zinit light zdharma/fast-syntax-highlighting
