#
# Editor configuration module for zsh.
#

# Define the default editor.
if (( $+commands[emacs] )) {
  export EDITOR='emacsclient -s terminal -t'
} elif (( $+commands[nano] )) {
  export EDITOR='nano'
}
export VISUAL="$EDITOR"
