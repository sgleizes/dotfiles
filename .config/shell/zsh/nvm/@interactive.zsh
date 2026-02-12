#
# NVM configuration module for zsh.
# https://github.com/nvm-sh/nvm
#

# Abort if requirements are not met.
if [[ ! -d "$XDG_CONFIG_HOME/nvm" ]]; then
  return 1
fi

export NVM_DIR="$XDG_CONFIG_HOME/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
