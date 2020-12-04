#
# Editor configuration module for zsh.
#

# Define the default editor.
if (( $+commands[emacs] )); then
  export EDITOR='emacsclient -s terminal -t'
elif (( $+commands[nano] )); then
  export EDITOR='nano'
fi
export VISUAL="$EDITOR"
