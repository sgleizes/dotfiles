#
# Term configuration module for zsh.
#

# Enable truecolor in terminal:
# https://github.com/syl20bnr/spacemacs/wiki/Terminal
#
# This is mainly necessary for emacs theme to load properly when daemon is
# started from systemd. Details are obscure.

# To setup xterm-24bit, run the following from this module directory:
# /usr/bin/tic -x -o ~/.local/share/terminfo xterm-24bit.terminfo
if [[ $TERM != (dumb|linux) && -f $TERMINFO/x/xterm-24bit ]]; then
  export TERM=xterm-24bit
fi
