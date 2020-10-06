#
# Installation module for spacemacs.
#

# Abort if requirements are not met.
if (( ! $+commands[emacs] )) {
  return 1
}

# Path to the emacs configuration directory.
export EMACS_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/emacs"

# Install spacemacs if necessary.
if [[ ! -f $EMACS_CONFIG_PATH/init.el ]] {
  print -P "%F{33}:: Installing syl20bnr/spacemacs...%f"
  command mkdir -p ${EMACS_CONFIG_PATH:h}
  command git clone 'https://github.com/syl20bnr/spacemacs' $EMACS_CONFIG_PATH \
    && print -P "%F{34}:: Installation successful%f%b" \
    || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }
}
