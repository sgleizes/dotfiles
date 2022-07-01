#
# ZI configuration module for zsh.
# https://github.com/z-shell/zi
#

# Paths for the zi installation.
typeset -gAH ZI
ZI[HOME_DIR]="${XDG_CONFIG_HOME:-$HOME/.config}/zi"
ZI[BIN_DIR]="$ZI[HOME_DIR]/bin"
ZI[ZCOMPDUMP_PATH]="$ZCACHEDIR/zcompdump"
ZPFX="$XDG_LIB_HOME/zi"

# Install zi if necessary.
if [[ ! -f $ZI[BIN_DIR]/zi.zsh ]]; then
  print -P "%F{33}:: Installing z-shell/zi...%f"
  command mkdir -p $ZI[HOME_DIR]
  command git clone 'https://github.com/z-shell/zi' $ZI[BIN_DIR] \
    && print -P "%F{34}:: Installation successful%f%b" \
    || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }

  # Patch scope: apply available patches to zi.
  patch_dir="${0:h}/patch"
  function {
    # Apply patch to git-process-output.
    local patch="$patch_dir/zi-git-process-output.patch"
    patch -d $ZI[BIN_DIR] -p1 -r- -suN <$patch |& grep -q 'FAILED' \
      && print -P ":: %F{red}ERROR%f: failed to apply $patch"
  }
  unset patch_dir
fi

# Automatically compile sourced scripts.
# To enable, run `zi module build`.
# To see the list of sourced files and their loading time, run `zpmod source-study -l`.
# BUG: This disables alias expansions from within sourced scripts.
# See https://github.com/zdharma/zinit/issues/339
# module_path+=($ZI[BIN_DIR]/zmodules/Src)
# zmodload -s z-shell/zplugin

# In the mean time this function does the job.
function xcompile {
  zcompile $ZI[ZCOMPDUMP_PATH]
  for rc in $XSH_CONFIG_DIR/zsh/**/*.zsh; do
    zcompile $rc
  done
}

# Source zi.
source $ZI[BIN_DIR]/zi.zsh

# Remove redundant zi aliases and functions.
unalias zini
unfunction zpcdclear zpcdreplay zpcompdef zpcompinit

# Install zi annexes.
zi light-mode depth=1 for \
  id-as'annex/bin-gem-node' z-shell/z-a-bin-gem-node \
  id-as'annex/patch-dl'     z-shell/z-a-patch-dl

# Install zi consolette for plugin management.
zi light-mode wait'0c' lucid depth=1 trackbinds for \
  id-as'lib/zui' blockf bindmap'^O^Z -> hold' z-shell/zui \
  id-as'app/ziconsole'  bindmap'^O^J -> ^O^Z' z-shell/zi-console
