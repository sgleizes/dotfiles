#
# Zinit module for zsh.
# https://github.com/zdharma/zinit
#

# Paths for the zinit installation.
typeset -gAH ZINIT
ZINIT[HOME_DIR]="${XDG_CONFIG_HOME:-$HOME/.config}/zinit"
ZINIT[ZCOMPDUMP_PATH]="$ZCACHEDIR/zcompdump"
ZPFX="$ZINIT[HOME_DIR]/prefix"

# Install zinit if necessary.
if [[ ! -f $ZINIT[HOME_DIR]/bin/zinit.zsh ]] {
  print -P "%F{33}:: Installing zdharma/zinit...%f"
  command mkdir -p $ZINIT[HOME_DIR]
  command git clone 'https://github.com/zdharma/zinit' $ZINIT[HOME_DIR]/bin \
    && print -P "%F{34}:: Installation successful%f%b" \
    || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }

  # Patch scope: apply available patches to zinit.
  patch_dir="${0:h}/patch"
  function {
    # Apply patch to git-process-output.
    local patch="$patch_dir/zinit-git-process-output.patch"
    patch -d $ZINIT[HOME_DIR]/bin -p1 -r- -suN <$patch |& grep -q 'FAILED' \
      && print -P ":: %F{red}ERROR%f: failed to apply $patch"
  }
  unset patch_dir
}

# Automatically compile sourced scripts.
# To enable, run `zinit module build`.
# To see the list of sourced files and their loading time, run `zpmod source-study -l`.
# BUG: This disables alias expansions from within sourced scripts.
# https://github.com/zdharma/zinit/issues/339
# module_path+=($ZINIT[HOME_DIR]/bin/zmodules/Src)
# zmodload -s zdharma/zplugin

# In the mean time this function does the job.
function xcompile {
  zcompile $ZINIT[ZCOMPDUMP_PATH]
  for rc in $XSH_CONFIG_DIR/zsh/module/**/*.zsh; { zcompile $rc; }
}

# Source zinit.
source $ZINIT[HOME_DIR]/bin/zinit.zsh

# Remove redundant zinit aliases and functions.
unalias zini zpl zplg
unfunction zpcdclear zpcdreplay zpcompdef zpcompinit zplugin
# Remove zinit prefix from path (unused so far).
path[1]=()

# Install zinit annexes.
zinit light-mode depth=1 for \
  zinit-zsh/z-a-bin-gem-node

# Install zinit consolette for plugin management.
zinit light-mode wait'0c' lucid depth=1 trackbinds for \
  blockf bindmap'^O^Z -> hold' zdharma/zui \
         bindmap'^O^J -> ^O^Z' zinit-zsh/zinit-console
