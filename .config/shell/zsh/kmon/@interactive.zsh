#
# Kmon configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Abort if requirements are not met.
if (( ! $+commands[kmon] )); then
  return 1
fi

if (( $terminfo[colors] >= 256 )); then
  alias kmon='kmon -u -c lightyellow'
fi

# Shortcut to open kmon.
# BUG: Arrows not working
function open-kmon {
  exec </dev/tty
  kmon
}
zle -N open-kmon
bindkey "$keys[Control]O$keys[Control]K" open-kmon
