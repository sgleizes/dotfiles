#
# Core installation module for zsh.
# This module installs optional core dependencies of the CLI environment using ZI.
#
# The ZSH_STANDALONE_INSTALL parameter is used as a conditional to enable this behavior
# across all modules. Dependencies defined here are those which are not related to a
# particular module.
# This parameter must be set before the interactive runcom initializes, so that ZI plugins
# are always registered even if already installed. Since this is a contextual parameter,
# preferably set this in ~/.pam_environment.
#

# Abort if requirements are not met.
if (( ! $+functions[zi] )) || [[ ! $ZSH_STANDALONE_INSTALL ]]; then
  return 1
fi

# TODO: zi delete does not remove man and completion automatically (for bat, fd, ...)
# TODO: zi delete does not uninstall programs installed to $ZPFX with make
# Uninstall:
# zi delete app/bat && zi cclear && rm -f $ZI[MAN_DIR]/man1/bat.1
# zi cd app/btop && make uninstall PREFIX=$ZPFX && cd - && zi delete app/btop
# zi delete app/fd && zi cclear && rm -f $ZI[MAN_DIR]/man1/fd.1
# zi cd app/neofetch && make uninstall PREFIX=$ZPFX && cd - && zi delete app/neofetch

# Install bat: https://github.com/sharkdp/bat
zi light-mode for id-as'app/bat' \
  from'gh-r' as'completion' nocompile lbin'!' \
  atclone'\mv -f bat-*/* . && rmdir bat-*/' \
  atclone'\cp -f autocomplete/bat.zsh _bat' \
  atclone"\cp -vf bat.1 $ZI[MAN_DIR]/man1" \
  atpull'%atclone' \
  @sharkdp/bat

# Install btop: https://github.com/aristocratos/btop
zi light-mode for id-as'app/btop' \
  from'gh-r' as'null' \
  make"install PREFIX=$ZPFX" \
  @aristocratos/btop

# Install fd: https://github.com/sharkdp/fd
zi light-mode for id-as'app/fd' \
  from'gh-r' as'completion' nocompile lbin'!' \
  atclone'\mv -f fd-*/* . && rmdir fd-*/' \
  atclone"\cp -vf fd.1 $ZI[MAN_DIR]/man1" \
  atpull'%atclone' \
  @sharkdp/fd

# Install neofetch: https://github.com/dylanaraps/neofetch
zi light-mode for id-as'app/neofetch' \
  depth=1 as'null' \
  make"install PREFIX=$ZPFX" \
  @dylanaraps/neofetch
