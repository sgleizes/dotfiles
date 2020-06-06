#
# Browser configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Convenience aliases.
alias browse='${(z)BROWSER}'
alias b='browse'

# Shortcut to open the default browser.
function open-browser {
  case $BROWSER in
    firefox*) browse 'about:newtab' ;;
    *) browse ;;
  esac
}
zle -N open-browser
bindkey "$keys[Control]O$keys[Control]B" open-browser
