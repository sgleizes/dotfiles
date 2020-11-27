#
# Installation module for doom emacs.
# https://github.com/hlissner/doom-emacs
#

# Abort if requirements are not met.
if (( ! $+commands[emacs] )) {
  return 1
}

# XDG path to the spacemacs configuration directory.
export DOOMDIR="${XDG_CONFIG_HOME:-$HOME/.config}/doom"
export DOOMLOCALDIR="${XDG_DATA_HOME:-$HOME/.local/share}/emacs"

# Path to the emacs configuration directory.
EMACSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/emacs"

# Install doom-emacs if necessary.
if [[ ! -f $EMACSDIR/init.el ]] {
  print -P "%F{33}:: Installing hlissner/doom-emacs...%f"
  command mkdir -p ${EMACSDIR:h}
  command git clone 'https://github.com/hlissner/doom-emacs' $EMACSDIR \
    && print -P "%F{34}:: Installation successful%f%b" \
    || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }

  # Install emacs packages.
  print -P "%F{33}:: Installing emacs packages...%f"
  $EMACSDIR/bin/doom install
}

# Add doom binaries to PATH.
path+=($EMACSDIR/bin)