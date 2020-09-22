#
# Kmon configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Abort if requirements are not met.
if (( ! $+commands[kmon] )) {
  return 1
}

if (( $terminfo[colors] >= 256 )) {
  alias kmon='kmon -u -c lightyellow'
}

# Shortcut to open kmon.
# BUG: Arrows not working
function open-kmon {
  exec </dev/tty
  kmon
}
zle -N open-kmon
bindkey "$keys[Control]O$keys[Control]K" open-kmon
