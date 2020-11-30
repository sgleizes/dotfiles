#
# Installation unit for spacemacs.
# https://github.com/syl20bnr/spacemacs
#

# Abort if requirements are not met.
if (( ! $+commands[emacs] )) {
  return 1
}

# XDG path to the spacemacs configuration directory.
export SPACEMACSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/spacemacs"

# Path to the emacs configuration directory.
EMACSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/emacs"

# Install spacemacs if necessary.
if [[ ! -f $EMACSDIR/init.el ]] {
  print -P "%F{33}:: Installing syl20bnr/spacemacs...%f"
  command mkdir -p ${EMACSDIR:h}
  command git clone 'https://github.com/syl20bnr/spacemacs' $EMACSDIR \
    && print -P "%F{34}:: Installation successful%f%b" \
    || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }
}
