#
# GPG configuration module for zsh.
#

# Return if requirements are not met.
if (( ! $+commands[gpg-agent] )) {
  return 1
}

# Inform gpg-agent of the current TTY for user prompts.
export GPG_TTY="$TTY"

# Updates the GPG-Agent TTY before every command since SSH does not set it.
# NOTE: This is here for completeness but is disabled since my setup avoids
# being prompted for passphrases altogehter.
# function _gpg-agent-update-tty {
#   gpg-connect-agent updatestartuptty /bye >/dev/null
# }
# autoload -Uz add-zsh-hook
# add-zsh-hook preexec _gpg-agent-update-tty
