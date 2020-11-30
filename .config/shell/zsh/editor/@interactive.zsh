#
# Editor configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Convenience aliases.
alias edit='${(z)VISUAL:-${(z)EDITOR}}'
alias e='edit'

if (( $+commands[emacs] )) {
  unalias edit

  # An emacs 'alias' with the ability to read from stdin.
  # Adopted from https://github.com/davidshepherd7/emacs-read-stdin/blob/master/emacs-read-stdin.sh
  function edit {
    # If the argument is - then write stdin to a tempfile and open the
    # tempfile.
    if (( $# >= 1 )) && [[ $1 == '-' ]]; then
      tempfile="$(mktemp "emacs-stdin-$USER.XXXXXXX" --tmpdir)"
      cat - >! $tempfile
      ${(z)VISUAL:-${(z)EDITOR}} \
        --eval "(find-file \"$tempfile\")" \
        --eval '(set-visited-file-name nil)' \
        --eval '(rename-buffer "*stdin*" t)'
    else
      ${(z)VISUAL:-${(z)EDITOR}} "$@"
    fi
  }

  # Install the emacs configuration framework.
  source ${0:h}/doom-emacs.zsh
}

# Shortcut to open the default editor.
function open-editor {
  exec </dev/tty
  edit
  zle redisplay
}
zle -N open-editor
bindkey "$keys[Control]O$keys[Control]E" open-editor
