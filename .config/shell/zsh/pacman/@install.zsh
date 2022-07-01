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

# List of pacman packages to prompt for automatic installation.
PACMAN_PACKAGE_LIST=(
  atool
  bat
  btop
  direnv
  emacs
  expac
  exa
  fd
  fzf
  fasd
  fortune-mod
  git-delta
  hex
  htop
  httpie
  hub
  imagemagick
  jq
  kmon
  lazygit
  mediainfo
  mlocate
  neofetch
  nnn
  pacman-contrib
  pastebinit
  ponysay
  rclone
  restic
  ripgrep
  rsync
  strace
  subversion
  tealdeer
  tmux
  trash-cli
  tree
  unison
  wget
  xclip
  youtube-dl
)

# List of AUR packages to hint for manual installation.
AUR_PACKAGE_LIST=(
  advcp
  archivemount
  fpp-git
  git-extras
  pistol-git
  tmux-xpanes
)

# Install missing optional packages for the terminal environment using pacman.
function install_packages {
  local pkgs ans

  pkgs=( $(missing_packages $PACMAN_PACKAGE_LIST[@]) )
  if [[ ! $pkgs ]]; then
    return
  fi

  print -P "%F{green}::%f The following optional CLI tools can be automatically installed:"
  print -f '  %s\n' $pkgs[@]
  print -Pn "%F{green}::%f Proceed? [Y/n] "
  read -sk ans; print
  if [[ $ans != (y|Y|$'\n') ]]; then
    return 1
  fi

  sudo pacman -Sy $pkgs[@]
  list_aur_packages
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
  printf '%s\n' $@ | grep -vE "^(${(j:|:)foreign_pkgs})" || true
}

if ! install_packages; then
  return 2
fi

# Reload the shell to update configuration with newly installed packages.
# NOTE: This is only executed if the shell is interactive (otherwise reload is undefined).
(( $+aliases[reload] )) && reload || true
