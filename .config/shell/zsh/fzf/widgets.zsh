#
# Custom ZLE widgets for FZF.
#

# Pick a directory from the output of the given command using fzf.
# Usage: _fzf_pick_dir <query> <cmd...>
function _fzf_pick_dir {
  setopt localoptions pipefail no_aliases 2>/dev/null

  eval "${@:2}" \
    | FZF_HEIGHT="${FZF_DIRS_HEIGHT:-${FZF_HEIGHT:-50%}}" \
      FZF_DEFAULT_OPTS="--reverse $FZF_DEFAULT_OPTS $FZF_DIRS_OPTS" \
      fzf +m -q "$1"
}

# Pick file(s) from the output of the given command using fzf.
# Usage: _fzf_pick_files <query> <cmd...>
function _fzf_pick_files {
  setopt localoptions pipefail no_aliases 2>/dev/null

  eval "${@:2}" \
    | FZF_HEIGHT="${FZF_FILES_HEIGHT:-${FZF_HEIGHT:-50%}}" \
      FZF_DEFAULT_OPTS="--reverse $FZF_DEFAULT_OPTS $FZF_FILES_OPTS" \
      fzf -m -q "$1" \
    | while { read item } { echo -n "${(q)item} " }
}

# Ensure precmds are run after cd.
function fzf-redraw-prompt {
  local precmd
  for precmd in $precmd_functions; do $precmd; done
  zle reset-prompt
}
zle -N fzf-redraw-prompt

# Select a directory using fzf to cd into.
function fzf-cd {
  () { # ensure local variables don't end up appearing in prompt expansion
    local selected
    local cmd="${FZF_DIRS_COMMAND:-"command find -L . -mindepth 1 \
      \\( \
        -path '*/\\.*' \
        -o -fstype 'sysfs' \
        -o -fstype 'devfs' \
        -o -fstype 'devtmpfs' \
        -o -fstype 'proc' \
      \\) -prune \
      -o -type d -print 2> /dev/null | cut -b3-"}"

    selected="$(_fzf_pick_dir "" "$cmd")" && cd "$selected"
  }

  local ___ret=$? # name unlikely to conflict with prompt expansions
  zle fzf-redraw-prompt
  return $___ret
}
zle -N fzf-cd

# Select local file path(s) using fzf and insert them into the command line.
function fzf-files {
  local tokens prefix lbuf selected ret

  # Extract the last word from the buffer.
  tokens=(${(z)LBUFFER})
  [[ ${LBUFFER[-1]} == ' ' ]] && tokens+=("")
  (( ${#tokens} > 0 )) && prefix="${tokens[-1]}"
  [[ ! ${tokens[-1]} ]] && lbuf="$LBUFFER" || lbuf="${LBUFFER:0:-${#tokens[-1]}}"

  local cmd="${FZF_FILES_COMMAND:-"command find -L . -mindepth 1 \
    \\( \
      -path '*/\\.*' \
      -o -fstype 'sysfs' \
      -o -fstype 'devfs' \
      -o -fstype 'devtmpfs' \
      -o -fstype 'proc' \
    \\) -prune \
    -o -type f -print 2>/dev/null | cut -b3-"}"
  selected="$(_fzf_pick_files "$prefix" "$cmd")"

  ret=$?
  LBUFFER="$lbuf$selected"
  zle redisplay
  return $ret
}
zle -N fzf-files

# Select `mlocate` file path(s) using fzf and insert them into the command line.
function fzf-locate {
  local cmd="${FZF_LOCATE_COMMAND:-"command locate /"}"
  FZF_FILES_COMMAND="$cmd" zle fzf-files
}
zle -N fzf-locate

# Search the history for a command using fzf.
function fzf-history {
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

  local selected accept num ret
  local opts="-n2..,.. --tiebreak=index --no-sort --expect=alt-a"
  selected=($(history -r 1 \
    | perl -ne 'print if !$seen{($_ =~ s/^\s*[0-9]+\s+//r)}++' \
    | FZF_HEIGHT="${FZF_HISTORY_HEIGHT:-${FZF_HEIGHT:-50%}}" \
      FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $opts $FZF_HISTORY_OPTS" \
      fzf --query=$LBUFFER +m))

  ret=$?
  if [[ $selected ]]; then
    # Figure out whether the entry should be accepted directly.
    accept=0
    if [[ $selected[1] == 'alt-a' ]]; then
      accept=1
      shift selected
    fi

    # Fetch the entry from history and update buffer.
    num=$selected[1]
    if [[ $num ]]; then
      zle vi-fetch-history -n $num
      [[ $accept = 1 ]] && zle accept-line
    fi
  fi

  zle reset-prompt
  return $ret
}
zle -N fzf-history
