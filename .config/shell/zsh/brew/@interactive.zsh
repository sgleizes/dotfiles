#
# Homebrew configuration module for zsh.
# https://github.com/Homebrew/brew
#

# Abort if requirements are not met.
if (( ! $+commands[brew] )); then
  return 1
fi

# Add competions for programs installed with homebrew to fpath.
# NOTE: This must run before compinit
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
