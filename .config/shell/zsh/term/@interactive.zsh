#
# Term configuration module for zsh.
#

# Enable truecolor in terminal.
# This is mainly necessary for emacs theme to load properly when daemon is
# started from systemd. Details are obscure.
# https://github.com/syl20bnr/spacemacs/wiki/Terminal
if [[ -f $TERMINFO/x/xterm-24bit ]]; then
  export TERM=xterm-24bit
fi
