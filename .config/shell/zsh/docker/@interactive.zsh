#
# Docker configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[docker] )); then
  return 1
fi

# NOTE: Loads of possible aliases, cherry pick as needed from:
# https://github.com/sorin-ionescu/prezto/blob/master/modules/docker/alias.zsh
alias dk='docker'

# Management commands
alias dkc='docker container'
alias dki='docker image'
alias dkn='docker network'
alias dks='docker service'
alias dkv='docker volume'

# Main commands
alias dka='docker attach'
alias dkb='docker build'
alias dke='docker exec'
alias dkr='docker run'
alias dkk='docker kill'
alias dkl='docker logs'

# Container (c)
alias dkcl='docker container ls'
alias dkcx='docker container rm'

# Image (i)
alias dkil='docker image ls'
alias dkih='docker image history'
alias dkit='docker image tag'
alias dkix='docker image rm'

# System
alias dkdf='docker system df'
alias dkpr='docker system prune'

# Extension for run-help to support 'docker' subcommands.
function run-help-docker {
  if (( $# == 0 )); then
    man docker
  elif (( $# >= 2 )) && man -w docker-$1-$2 &>/dev/null; then
    man docker-$1-$2
  else
    man docker-$1
  fi
}

# Support for docker-compose.
if (( $+commands[docker-compose] )); then
  alias dcp='docker-compose'
fi

# Integration with the fuzzy finder.
if (( $+commands[fzf] )); then
  # Select a docker container to show logs of.
  function fzf-docker-logs() {
    local selected
    selected=($(docker container ls -a \
      | sed 1d \
      | FZF_HEIGHT=${FZF_HEIGHT:-55%} fzf +m -q "$1" \
      | awk '{print $1}'))

    [[ $selected ]] && docker logs $selected
  }

  # Select docker containers to remove.
  function fzf-docker-rm() {
    local selected
    selected=($(docker container ls -a \
      | sed 1d \
      | FZF_HEIGHT=${FZF_HEIGHT:-55%} fzf -m -q "$1" \
      | awk '{print $1}'))

    [[ $selected ]] && docker rm $selected
  }

  # Select docker images to remove.
  function fzf-docker-rmi() {
    local selected
    selected=($(docker image ls \
      | sed 1d \
      | FZF_HEIGHT=${FZF_HEIGHT:-55%} fzf -m -q "$1" \
      | awk '{print $3}'))

    [[ $selected ]] && docker rmi $selected
  }

  alias dklf='fzf-docker-logs'
  alias dkcxf='fzf-docker-rm'
  alias dkixf='fzf-docker-rmi'
fi
