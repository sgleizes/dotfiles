#
# Direnv configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[direnv] )) {
  return 1
}

# Setup and cache the shell hook.
direnv_cache="$XDG_CACHE_HOME/direnv/hook.zsh"
if [[ ! -s "$direnv_cache" || $commands[direnv] -nt $direnv_cache ]] {
  command mkdir -p ${direnv_cache:h} && direnv hook zsh >|"$direnv_cache"
}
source "$direnv_cache"

unset direnv_cache
