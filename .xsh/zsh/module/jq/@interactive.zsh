#
# Interactive jq filter builder for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[jq] || ! $+commands[fzf] )) {
  return 1
}

# Interactive jq filter builder using fzf.
# Usage: jq-repl [input]
function jq-repl {
  local input="$1"
  if [[ ! $input || $input == '-' ]] {
    input=$(mktemp)
    trap "command rm -f $input" EXIT
    cat /dev/stdin >|$input
  }

  </dev/null fzf \
    --phony \
    --print-query \
    --preview "jq --color-output -r {q} $input" \
    --preview-window="down:99%" \
    --query="."
}

# ZLE widget to invoke jq-repl on the output of the current command.
function jq-complete {
  local query="$(eval "$LBUFFER" | jq-repl)"
  local ret=$?
  if [[ $query ]] {
    LBUFFER="${LBUFFER} | jq -r '$query'"
  }
  zle redisplay
  return $ret
}

zle -N jq-complete
bindkey "$keys[Alt]J" jq-complete
