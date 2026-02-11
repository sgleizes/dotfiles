#
# Fuzzy finder configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Install fzf if standalone install is requested.
if (( $+functions[zi] )) && [[ $ZSH_STANDALONE_INSTALL ]]; then
  # Uninstall: zi delete app/fzf && rm -f $ZI[MAN_DIR]/man1/fzf*.1
  zi light-mode for id-as'app/fzf' \
    depth=1 as'null' lbin'!bin/fzf' \
    atclone'./install --bin' \
    atclone"\cp -rvf man/* $ZI[MAN_DIR]/" \
    atpull'%atclone' \
    @junegunn/fzf
fi

# Abort if requirements are not met.
if (( ! $+commands[fzf] )); then
  return 1
fi

# Import default fzf options.
fzf_config="$XDG_CONFIG_HOME/fzf/config"
(( $terminfo[colors] < 256 )) && fzf_config="${fzf_config}-portable"
if [[ -r $fzf_config ]]; then
  export FZF_DEFAULT_OPTS="$(grep -vE '^$|^#' $fzf_config)"
fi

# Additional bindings in fzf context.
FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--bind ctrl-space:toggle+down
--bind alt-s:toggle-sort
--bind alt-p:toggle-preview
--bind alt-a:toggle-all
--bind alt-g:top
--bind ctrl-f:page-down
--bind ctrl-b:page-up
--bind ctrl-d:half-page-down
--bind ctrl-u:half-page-up
--bind shift-down:preview-down
--bind shift-up:preview-up
--bind alt-j:preview-down
--bind alt-k:preview-up
--bind alt-J:preview-page-down
--bind alt-K:preview-page-up'

# Abstract away the fzf command for optional tmux integration.
function fzf {
  local height="${FZF_HEIGHT:-50%}"

  if [[ $TMUX_PANE && $FZF_TMUX ]]; then
    fzf-tmux -p $height -- "$@"
  else
    command fzf --height $height "$@"
  fi
}

# Add fzf-completion widget.
fzf_completion=(
  $ZI[PLUGINS_DIR]/app---fzf/shell/completion.zsh(N)
  $HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh(N)
  $XDG_DATA_HOME/fzf/completion.zsh(N)
  /usr/share/fzf/completion.zsh(N)
  /usr/share/doc/fzf/examples/completion.zsh(N)
)
if [[ -r $fzf_completion[1] ]]; then
  source $fzf_completion[1]
  source ${0:h}/completion.zsh

  # Use a dedicated key instead of a trigger sequence for fuzzy completion.
  FZF_COMPLETION_TRIGGER=''
  bindkey "$keys[Control]F" fzf-completion
  bindkey "$keys[Control]I" "$fzf_default_completion"

  # Automatically select single matches.
  FZF_COMPLETION_OPTS="--select-1"
  # Add aliases to commands accepting directories.
  FZF_COMPLETION_DIR_COMMANDS=(cd pushd rmdir rmd)
fi

# Additional ZLE widgets.
source ${0:h}/widgets.zsh
bindkey "$keys[Control]R" fzf-history
bindkey "$keys[Alt]L"     fzf-locate
bindkey "$keys[Alt]F"     fzf-files
bindkey "$keys[Alt]C"     fzf-cd

# Use `fd` instead of `find` if available.
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --follow --hidden --exclude .git --exclude dosdevices'
  FZF_FILES_COMMAND="$FZF_DEFAULT_COMMAND --type f"
  FZF_DIRS_COMMAND="$FZF_DEFAULT_COMMAND --type d"
fi

# Use `pistol` if available.
if (( $+commands[pistol] )); then
  fzf_dir_preview='pistol'
  fzf_file_preview='pistol'
else
  fzf_dir_preview='tree -C'
  fzf_file_preview='cat'
fi

# Custom fzf options for ZLE widgets.
FZF_HISTORY_OPTS="--no-reverse"
FZF_DIRS_OPTS="--select-1 --preview '$fzf_dir_preview {} | head -200'"
FZF_FILES_OPTS="--no-height --preview '$fzf_file_preview {} 2>/dev/null | head -1000' --preview-window=wrap"
FZF_FILES_HEIGHT='90%'

unset fzf_{config,completion,file_preview}
