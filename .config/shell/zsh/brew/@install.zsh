#
# Brew installation module for zsh.
# This module installs dependencies of the CLI environment using homebrew.
#
# Usage: xsh load brew install
#

# Abort if requirements are not met.
if (( ! $+commands[brew] )); then
  return 1
fi

# Lists of homebrew packages to prompt for automatic installation.
BREW_PACKAGES_BASIC=(
  # NOTE: Missing recipe
  # advcp
  atool
  bat
  btop
  exa
  fd
  fzf
  fasd
  # NOTE: Missing recipe
  # hex
  htop
  # NOTE: Missing recipe
  # mlocate
  neofetch
  nnn
  # NOTE: Missing recipe
  # pistol
  ripgrep
  trash-cli
  tree
  wget
)
BREW_PACKAGES_DEV=(
  archivemount
  direnv
  # NOTE: Built --without-x
  # emacs
  fpp
  git-delta
  git-extras
  httpie
  hub
  imagemagick
  jq
  media-info
  pastebinit
  rsync
  strace
  # NOTE: Fails to build from source due to missing gawk
  # subversion
  tealdeer
  tmux
  tmux-xpanes
  xclip
)
BREW_PACKAGES_EXTRA=(
  fortune
  # NOTE: Missing recipe
  # kmon
  lazygit
  ponysay
  rclone
  restic
  unison
  youtube-dl
)

# Prompt for installation of the given package group using homebrew.
# Usage: install_packages <group> <pkgs...>
function install_packages {
  local group=$1
  local pkgs ans

  pkgs=( $(missing_packages ${@:2}) )
  if [[ ! $pkgs ]]; then
    return
  fi

  print -Pn "%F{green}::%f Install $group CLI packages using brew? [Y/n] "
  read -sk ans; print
  if [[ $ans != (y|Y|$'\n') ]]; then
    return
  fi

  for pkg in $pkgs[@]; do
    if ! install_package $pkg; then
      return 1
    fi
  done
}

# Prompt for installation of the given package using homebrew.
function install_package {
  local pkg=$1
  local ans

  print -Pn "%F{green}::%f Install $pkg? [Y/n] "
  read -sk ans; print
  if [[ $ans != (y|Y|$'\n') ]]; then
    return
  fi

  brew install $pkg
}

# List packages that are missing among provided arguments.
function missing_packages {
  print -l $@ | grep -vE "${(j:|:)$(brew list)}" || true
}

if ! install_packages 'basic' $BREW_PACKAGES_BASIC[@] \
   || ! install_packages 'dev' $BREW_PACKAGES_DEV[@] \
   || ! install_packages 'extra' $BREW_PACKAGES_EXTRA[@]; then
  return 2
fi

# Reload the shell to update configuration with newly installed packages.
# NOTE: This is only executed if the shell is interactive (otherwise reload is undefined).
(( $+aliases[reload] )) && reload || true
