#
# Installation unit for doom emacs.
# https://github.com/hlissner/doom-emacs
#

# Abort if requirements are not met.
if (( ! $+commands[emacs] )); then
  return 1
fi

# XDG path to the spacemacs configuration directory.
export DOOMDIR="${XDG_CONFIG_HOME:-$HOME/.config}/doom"
export DOOMLOCALDIR="${XDG_DATA_HOME:-$HOME/.local/share}/emacs"

# Path to the emacs configuration directory.
EMACSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/emacs"

# Install doom-emacs if necessary.
if [[ ! -f $EMACSDIR/init.el ]]; then
  print -P "%F{33}:: Installing hlissner/doom-emacs...%f"
  command mkdir -p ${EMACSDIR:h}
  command git clone 'https://github.com/hlissner/doom-emacs' $EMACSDIR \
    && print -P "%F{34}:: Installation successful%f%b" \
    || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }

  # Setup doom and install emacs packages.
  print -P "%F{33}:: Setting up Doom Emacs...%f"
  $EMACSDIR/bin/doom install
  print -P "%F{33}:: Synchronizing with literate config...%f"
  $EMACSDIR/bin/doom sync
fi

# Add doom binaries to PATH.
path+=($EMACSDIR/bin)
