#
# Syntax highlighting configuration module for zsh.
#
# NOTE: This module should be loaded after all ZLE widgets have been defined.
# In general, that means after completion and ZLE settings.
#

# Abort if requirements are not met.
if [[ $TERM == 'dumb' || $+functions[zi] == 0 ]]; then
  return 1
fi

# Syntax highlighting plugin with the default theme.
# Use `fast-theme` to configure.
zi ice wait lucid depth=1 atload'unalias fsh-alias'
zi light z-shell/fast-syntax-highlighting
