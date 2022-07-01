#
# Homebrew configuration module for zsh.
# https://github.com/Homebrew/brew
#

# NOTE: WIP

# Abort if requirements are not met.
if (( ! $+commands[brew] )); then
  return 1
fi

# # Paths for the homebrew installation.
# HOMEBREW_PREFIX="$XDG_LIB_HOME/brew"

# TODO: Don't install, just configure (like pacman)
# # Install homebrew if necessary.
# if [[ ! -d $HOMEBREW_PREFIX/bin ]]; then
#   print -P "%F{33}:: Installing Homebrew/brew...%f"
#   command git clone 'https://github.com/Homebrew/brew' $HOMEBREW_PREFIX \
#     && print -P "%F{34}:: Installation successful%f%b" \
#     || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }
# fi

# eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# TODO: Needs to run first time only, but after shellenv
# brew update --force --silent

# NOTE: This must run before compinit
# fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# TODO: ENV config
# export HOMEBREW_NO_ENV_HINTS=1
