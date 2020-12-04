#
# Fasd configuration module for zsh
#
# NOTE: This module uses the open/edit aliases and therefore depends
# on the core/editor modules.
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Abort if requirements are not met.
if (( ! $+commands[fasd] )); then
  return 1
fi

# Configuration options.
export _FASD_DATA="$XDG_DATA_HOME/recently-used.fasd"
_FASD_IGNORE="fasd echo ls l ll la"

# Use fasd as a function instead of an executable.
source $commands[fasd]

# Add preexec hook.
function _fasd_preexec {
  { eval "fasd --proc $(fasd --sanitize $1)"; } >>/dev/null 2>&1
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _fasd_preexec

# Pick a frecent file/directory.
# Usage: fasd_pick <a|f|d> [query...]
function _fasd_pick {
  local qtype="${1:-a}"
  [[ $1 ]] && shift

  if (( $# == 0 )); then
    # Interactively select a file/directory.
    if (( $+commands[fzf] )); then
      fasd -$qtype -Rl | FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --no-sort" fzf
    else
      fasd -$qtype -i
    fi
  else
    # Query fasd for a file/directory using the provided arguments.
    fasd -$qtype $@
  fi
}

# Change to a frecent directory.
# Usage: fasd-cd [query...]
function fasd-cd {
  local dir=$(FZF_HEIGHT="${FZF_DIRS_HEIGHT:-${FZF_HEIGHT:-50%}}" \
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_DIRS_OPTS +m" \
    _fasd_pick d $@)
  [[ -d $dir ]] && cd $dir || return 1
}

# Edit frecent files.
# Usage: fasd-edit [query...]
function fasd-edit {
  local files=$(FZF_HEIGHT="${FZF_FILES_HEIGHT:-${FZF_HEIGHT:-50%}}" \
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_FILES_OPTS -m" \
    _fasd_pick f $@)
  [[ $files ]] && edit ${(f)files} || return 1
}

# Open frecent files.
# Usage: fasd-open [query...]
function fasd-open {
  local files=$(FZF_HEIGHT="${FZF_FILES_HEIGHT:-${FZF_HEIGHT:-50%}}" \
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_FILES_OPTS -m" \
    _fasd_pick f $@)
  [[ $files ]] && for f in ${(f)files}; { open $f || return 1; }
}

alias d='fasd -d'
alias dc='fasd-cd'
alias f='fasd -f'
alias fe='fasd-edit'
alias fo='fasd-open'

#
# Completion widgets
#

# Register fasd completion matches.
# Usage: _fasd_compgen <qtype> <word>
function _fasd_compgen {
  local tag desc expl
  case $1 in
    e) tag='all-files' desc='frecent paths' ;;
    f) tag='files' desc='frecent files' ;;
    d) tag='directories' desc='frecent directories' ;;
  esac

  _description -V "$tag" expl "$desc"
  compadd $expl[@] -UQ - \
    ${(f)"$(fasd --query "$1" "$2" 2>/dev/null | sort -nr | sed 's/^[^ ]*[ ]*//')"}
}

# Completion widget for fasd frecent files and directories.
# Usage: _fasd_word_complete [<qtype>] [<word>]
function _fasd_word_complete {
  local qtype cword expl
  local continue=1

  qtype=${1:-e}
  cword="${2:-$words[CURRENT]}"
  cword="${cword//,/ }" # remove fasd trigger

  [[ $qtype == (e|f) ]] && _fasd_compgen f "$cword" && continue=0
  [[ $qtype == (e|d) ]] && _fasd_compgen d "$cword" && continue=0

  # Add the original string as a match.
  if (( $compstate[nmatches] > 1 )) \
    || zstyle -t ":completion:${curcontext}:" original; then
    _description -V original expl original
    compadd $expl[@] -UQ - "$PREFIX$SUFFIX"
  fi

  compstate[insert]='automenu' # no expand
  return $continue
}

# Specialized completion widgets.
function _fasd_word_complete_files { _fasd_word_complete f; }
function _fasd_word_complete_dirs { _fasd_word_complete d; }

# Trigger-based completer.
function _fasd_word_complete_trigger {
  local cword="${words[CURRENT]}" fasd_comp
  fasd_comp="$(fasd --word-complete-trigger _fasd_word_complete $cword)"

  # Ensure the completion continues if no trigger was found.
  [[ $fasd_comp ]] && eval "$fasd_comp" || return 1
}

# Register fasd completion widgets.
zle -C fasd-complete complete-word _generic
zle -C fasd-complete-files complete-word _generic
zle -C fasd-complete-dirs complete-word _generic
zstyle ':completion:fasd-complete:*' completer _fasd_word_complete
zstyle ':completion:fasd-complete-files:*' completer _fasd_word_complete_files
zstyle ':completion:fasd-complete-dirs:*' completer _fasd_word_complete_dirs

# Add fasd trigger to primary completers.
_primary_completers+=(_fasd_word_complete_trigger)

#
# Editor widgets
#

if (( ! $+commands[fzf] )); then
  return 2
fi

# Select a frecent directory using fzf to cd into.
function fzf-fasd-cd {
  FZF_DIRS_COMMAND="fasd -d -Rl $*" \
  FZF_DIRS_OPTS="$FZF_DIRS_OPTS --no-sort" \
    zle fzf-cd
}
zle -N fzf-fasd-cd

# Select frecent file path(s) using fzf and insert them into the command line.
function fzf-fasd-files {
  FZF_FILES_COMMAND="fasd -f -Rl $*" \
  FZF_FILES_OPTS="$FZF_FILES_OPTS --no-sort" \
    zle fzf-files
}
zle -N fzf-fasd-files

bindkey "$keys[Alt]c" fzf-fasd-cd
bindkey "$keys[Alt]f" fzf-fasd-files
