#
# Aptitude installation module for zsh.
# This module installs dependencies of the CLI environment using apt.
#
# Usage: xsh load aptitude install
#

# Abort if requirements are not met.
if (( ! $+commands[apt] )); then
  return 1
fi

# Lists of apt packages to prompt for automatic installation.
APT_PACKAGES_BASIC=(
  atool
  bat
  btop
  eza
  fd-find
  fasd
  fzf
  htop
  fastfetch
  nnn
  ripgrep
  trash-cli
  tree
  wget
)
APT_PACKAGES_DEV=(
  archivemount
  direnv
  emacs
  fonts-open-sans
  git-delta
  git-extras
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
  wl-clipboard
)
APT_PACKAGES_EXTRA=(
  fortune-mod
  kmon
  rclone
  restic
  yt-dlp
)

# List of packages to hint for manual installation.
APT_MANUAL_PACKAGE_LIST=(
  advcpmv
  pistol
  ponysay
  tmux-xpanes
)

# List packages that are missing among provided arguments.
function missing_apt_packages {
  installed=($(dpkg-query --show -f '${Package}\n' | grep -E "^(${(j:|:)@})$"))
  print -l "$@" | grep -vE "^(${(j:|:)installed[@]})$" || true
}

# Prompt for installation of the given package group using apt.
# Usage: install_packages <group> <pkgs...>
function install_apt_packages {
  local group=$1
  local pkgs ans

  pkgs=( $(missing_apt_packages ${@:2}) )
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

  sudo apt install -y $pkgs[@]
}

# List manual packages.
function list_manual_packages {
  local pkgs

  pkgs=( $APT_MANUAL_PACKAGE_LIST[@] )
  if [[ ! $pkgs ]]; then
    return
  fi

  print -P "%F{yellow}::%f The following optional packages may need to be installed manually:"
  print -f '  %s\n' $pkgs[@]
}

if ! install_apt_packages 'basic' $APT_PACKAGES_BASIC[@] \
   || ! install_apt_packages 'dev' $APT_PACKAGES_DEV[@] \
   || ! install_apt_packages 'extra' $APT_PACKAGES_EXTRA[@]; then
  return 2
fi

# List additiona packages that could not be installed via pacman.
list_manual_packages

# Create links to binaries with conflicting names on debian
print -P "%F{yellow}::%f Creating local links for binaries with conflicting names:"
if (( $+commands[fdfind] )); then
  ln -sf "$(which fdfind)" ~/.local/bin/fd
fi
if (( $+commands[batcat] )); then
  ln -sf "$(which batcat)" ~/.local/bin/bat
fi

# Reload the shell to update configuration with newly installed packages.
# NOTE: This is only executed if the shell is interactive (otherwise reload is undefined).
(( $+aliases[reload] )) && reload || true
