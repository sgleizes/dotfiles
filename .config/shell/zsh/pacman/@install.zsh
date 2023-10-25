#
# Pacman installation module for zsh.
# This module installs dependencies of the CLI environment using pacman.
#
# Usage: xsh load pacman install
#

# Abort if requirements are not met.
if (( ! $+commands[pacman] )); then
  return 1
fi

# Lists of pacman packages to prompt for automatic installation.
PACMAN_PACKAGES_BASIC=(
  atool
  bat
  btop
  eza
  fd
  fasd
  fzf
  hex
  htop
  mlocate
  neofetch
  nnn
  ripgrep
  trash-cli
  tree
  wget
)
PACMAN_PACKAGES_DEV=(
  direnv
  emacs
  git-delta
  glow
  httpie
  hub
  imagemagick
  jq
  mediainfo
  pastebinit
  rsync
  strace
  subversion
  tealdeer
  tmux
  xclip
)
PACMAN_PACKAGES_EXTRA=(
  expac
  fortune-mod
  kmon
  pacman-contrib
  ponysay
  rclone
  restic
  unison
  yt-dlp
)

# List of AUR packages to hint for manual installation.
AUR_PACKAGE_LIST=(
  advcpmv
  archivemount
  git-extras
  pistol-git
  tmux-xpanes
)

# Prompt for installation of the given package group using pacman.
# Usage: install_packages <group> <pkgs...>
function install_packages {
  local group=$1
  local pkgs ans

  pkgs=( $(missing_packages ${@:2}) )
  if [[ ! $pkgs ]]; then
    return
  fi

  print -P "%F{green}::%f The following $group CLI packages can be installed using pacman:"
  print -f '  %s\n' $pkgs[@]
  print -Pn "%F{green}::%f Proceed? [Y/n] "
  read -sk ans; print
  if [[ $ans != (y|Y|$'\n') ]]; then
    return
  fi

  sudo pacman -Sy $pkgs[@]
}

# List missing AUR packages.
function list_aur_packages {
  local pkgs

  pkgs=( $(missing_aur_packages $AUR_PACKAGE_LIST[@]) )
  if [[ ! $pkgs ]]; then
    return
  fi

  print -P "%F{yellow}::%f The following packages can be built manually from the AUR:"
  print -f '  %s\n' $pkgs[@]
}

# List packages that are missing among provided arguments.
function missing_packages {
  pacman -Sl | awk '{print $2,$4}' | grep -E "^(${(j:|:)@}) $" || true
}

# List AUR packages that are missing among provided arguments.
function missing_aur_packages {
  local foreign_pkgs

  foreign_pkgs=( $(pacman -Qqem) )
  if [[ ! $foreign_pkgs ]]; then
    print -l $@
  fi

  print -l $@ | grep -vE "^(${(j:|:)foreign_pkgs})" || true
}

if ! install_packages 'basic' $PACMAN_PACKAGES_BASIC[@] \
   || ! install_packages 'dev' $PACMAN_PACKAGES_DEV[@] \
   || ! install_packages 'extra' $PACMAN_PACKAGES_EXTRA[@]; then
  return 2
fi

# List additiona packages that could not be installed via pacman.
list_aur_packages

# Reload the shell to update configuration with newly installed packages.
# NOTE: This is only executed if the shell is interactive (otherwise reload is undefined).
(( $+aliases[reload] )) && reload || true
