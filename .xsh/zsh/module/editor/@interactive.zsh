#
# Editor configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Convenience aliases.
alias edit='${(z)VISUAL:-${(z)EDITOR}}'
alias e='edit'

# Shortcut to open the default editor.
function open-editor {
  exec </dev/tty
  edit
  zle redisplay
}
zle -N open-editor
bindkey "$keys[Control]O$keys[Control]E" open-editor
