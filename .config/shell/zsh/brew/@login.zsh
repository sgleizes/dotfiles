#
# Homebrew configuration module for zsh.
# https://github.com/Homebrew/brew
#

# Paths for the homebrew installation.
homebrew=(
  /home/linuxbrew/.linuxbrew(N)
  $HOME/.linuxbrew(N)
  $XDG_LIB_HOME/brew(N)
)

# Abort if requirements are not met.
if [[ ! -d $homebrew[1] || ! -r $homebrew[1]/bin/brew ]]; then
  unset homebrew
  return 1
fi

eval "$($homebrew[1]/bin/brew shellenv)"
unset homebrew
