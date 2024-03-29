#
# Ripgrep configuration module for zsh.
#

# Install ripgrep if standalone install is requested.
if (( $+functions[zi] )) && [[ $ZSH_STANDALONE_INSTALL ]]; then
  # Uninstall: zi delete app/ripgrep && zi cclear && rm -f $ZI[MAN_DIR]/man1/rg.1
  zi light-mode for id-as'app/ripgrep' \
    from'gh-r' as'completion' nocompile lbin'!rg' \
    atclone'\mv -f ripgrep-*/* . && rmdir ripgrep-*/' \
    atclone"\cp -vf doc/rg.1 $ZI[MAN_DIR]/man1" \
    atpull'%atclone' \
    @BurntSushi/ripgrep
fi

# Abort of requirements are not met.
if (( ! $+commands[rg] )); then
  return 1
fi

# Path to configuration file.
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"

# Check dependencies for interactive searches.
if (( ! $+commands[fzf] )); then
  return 2
fi

# Default rg commands for integration with fzf.
FZF_RG_COMMAND='noglob rg --files-with-matches --no-messages'
FZF_RG_PREVIEW='noglob rg --pretty --context=10 2>/dev/null'

# Search file contents for the given pattern and preview matches.
# Selected entries are opened with the default opener.
#
# Usage: search <pattern> [rg-options...]
function search {
  [[ ! $1 || $1 == -* ]] && echo "fs: missing rg pattern" && return 1
  local pat="$1" && shift

  local selected=($( \
    FZF_HEIGHT=${FZF_HEIGHT:-90%} \
    FZF_DEFAULT_COMMAND="$FZF_RG_COMMAND $* '$pat'" \
    fzf \
      --multi \
      --preview "$FZF_RG_PREVIEW $* '$pat' {}" \
      --preview-window=wrap
  ))

  # Open selected files.
  [[ $selected ]] && for f in ${selected}; do open $f || return 1; done
}

# Search files interactively and preview matches.
# Selected entries are opened with the default opener.
# NOTE: The optional directory MUST be given as first argument,
# otherwise the behavior is undefined.
#
# Usage: search-interactive [dir] [rg-options...]
function search-interactive {
  local dir
  [[ $1 && $1 != -* ]] && dir=$1 && shift

  local selected=($( \
    FZF_HEIGHT=${FZF_HEIGHT:-90%} \
    FZF_DEFAULT_COMMAND="rg --files $* $dir" \
    fzf \
      --multi \
      --phony \
      --bind "change:reload:$FZF_RG_COMMAND {q} $* $dir || true" \
      --preview "$FZF_RG_PREVIEW {q} {} $*" \
      --preview-window=wrap \
    | cut -d":" -f1,2
  ))

  # Open selected files.
  [[ $selected ]] && for f in ${selected}; do open $f || return 1; done
}

# Interactive search variant that sorts the results.
# This disables parallelism and makes searches much slower.
function search-interactive-sorted {
  search-interactive "$@" --sort=path
}

# Usability aliases.
alias fs='search'
alias ff='search-interactive'
alias ffs='search-interactive-sorted'

# Add function dir to fpath for completions.
autoload_dir ${0:h}/function
