#
# Editor configuration module for zsh.
#

# Define the default editor.
export EDITOR='emacsclient -t'
export VISUAL="$EDITOR"

# Define the location of the emacs socket.
# For this to work, a systemd socket for the emacs service must be enabled and started.
# When emacsclient connects to it for the first time, systemd will launch the Emacs server.
export EMACS_SOCKET_NAME="${XDG_RUNTIME_DIR:-/run}/emacs.socket"
