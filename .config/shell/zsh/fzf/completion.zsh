#
# Custom completion definitions for FZF.
#

# Fuzzy completion for kill.
function _fzf_complete_kill {
  local ps_cmd
  zstyle -a ':completion:*:processes' command ps_cmd || ps_cmd=(ps -u $USER)

  _fzf_complete -m --min-height 15 --preview 'echo {}' --preview-window down:3:wrap -- "$@" < <(
    command ${(ez)ps_cmd} | sed 1d
  )
}
function _fzf_complete_kill_post {
  awk '{print $1}'
}

# Fuzzy completion for killall.
function _fzf_complete_killall {
  local ps_cmd
  zstyle -a ':completion:*:processes-names' command ps_cmd || ps_cmd=(ps -u $USER)

  _fzf_complete -m --min-height 15 --preview 'nm={}; ps -fC ${nm:0:15}' -- "$@" < <(
    command ${(ez)ps_cmd} | sed 1d | awk '{sub(".*/", "", $1); print $1}' | sort -u
  )
}

# Use `fd` instead of the default `find` commands for path/directory completion.
# The first argument is the base path to start traversal.
if (( $+commands[fd] )); then
  _fzf_compgen_path() {
    fd --hidden --follow --exclude '.git' . $1
  }
  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude '.git' . $1
  }
fi

# Customization of fzf options by command.
function _fzf_comprun {
  local cmd=$1
  shift

  case $cmd in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" --preview-window down:3:wrap ;;
#     ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}

# Redefinition of the fzf completion widget.
# This is primarily done to avoid treating `kill` completion specially.
function fzf-completion {
  local tokens cmd prefix trigger tail lbuf d_cmds
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  tokens=(${(z)LBUFFER})
  if (( ${#tokens} < 1 )); then
    zle ${fzf_default_completion:-expand-or-complete}
    return
  fi

  cmd=$(__fzf_extract_command $LBUFFER)

  # Explicitly allow for empty trigger.
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  [[ ! $trigger && ${LBUFFER[-1]} == ' ' ]] && tokens+=("")

  # When the trigger starts with ';', it becomes a separate token.
  if [[ $LBUFFER == *${tokens[-2]}${tokens[-1]} ]]; then
    tokens[-2]="${tokens[-2]}${tokens[-1]}"
    tokens=(${tokens[0,-2]})
  fi

  tail=${LBUFFER:$(( ${#LBUFFER} - ${#trigger} ))}
  # Trigger sequence given.
  if [[ ${#tokens} -gt 1 && $tail == $trigger ]]; then
    d_cmds=(${=FZF_COMPLETION_DIR_COMMANDS:-cd pushd rmdir})

    [[ ! $trigger      ]] && prefix="${tokens[-1]}" || prefix="${tokens[-1]:0:-${#trigger}}"
    [[ ! ${tokens[-1]} ]] && lbuf="$LBUFFER"        || lbuf="${LBUFFER:0:-${#tokens[-1]}}"

    if eval "type _fzf_complete_${cmd} >/dev/null"; then
      prefix="$prefix" eval _fzf_complete_${cmd} ${(q)lbuf}
    elif [[ ${d_cmds[(i)$cmd]} -le ${#d_cmds} ]]; then
      _fzf_dir_completion "$prefix" "$lbuf"
    else
      _fzf_path_completion "$prefix" "$lbuf"
    fi
  # Fall back to default completion.
  else
    zle ${fzf_default_completion:-expand-or-complete}
  fi
}
