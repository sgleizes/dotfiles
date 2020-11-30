#
# Prezto module for zsh.
# https://github.com/sorin-ionescu/prezto
#

# Path to the prezto installation.
PREZTO_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/prezto"

# Source the prezto configuration.
source ${0:h}/preztorc

# Install prezto if necessary.
if [[ ! -d $PREZTO_DIR ]]; then
  print -P "%F{33}:: Installing sorin-ionescu/prezto...%f"
  command git clone --recursive 'https://github.com/sorin-ionescu/prezto' $PREZTO_DIR \
    && print -P "%F{34}:: Installation successful%f%b" \
    || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }
fi

# Source prezto.
source $PREZTO_DIR/init.zsh

# Source the original prezto runcom if the shell is a login shell.
if [[ -o LOGIN ]]; then
  source $PREZTO_DIR/runcoms/zlogin
fi
