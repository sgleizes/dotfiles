#
# Installation module for the tmux plugin manager.
#

# Abort if requirements are not met.
if (( ! $+commands[tmux] )) {
  return 1
}

# Path to the tpm plugin directory.
export TMUX_PLUGIN_MANAGER_PATH="${0:h}/tpm"

# Path to the tpm patch directory.
export TMUX_PLUGIN_MANAGER_PATCH_DIR="${0:h}/patch"

# Install tpm if necessary.
if [[ ! -f $TMUX_PLUGIN_MANAGER_PATH/tpm/tpm ]] {
  print -P "%F{33}:: Installing tmux-plugins/tpm...%f"
  command mkdir -p $TMUX_PLUGIN_MANAGER_PATH
  command git clone 'https://github.com/tmux-plugins/tpm' $TMUX_PLUGIN_MANAGER_PATH/tpm \
    && print -P "%F{34}:: Installation successful%f%b" \
    || { print -P "%F{160}:: The clone has failed%f%b" && return 1 }

  # Patch scope: apply available patches to tpm.
  function {
    # Improve tpm logging by using status messages instead of hidden echo.
    local patch="$TMUX_PLUGIN_MANAGER_PATCH_DIR/tpm-messages.patch"
    patch -d $TMUX_PLUGIN_MANAGER_PATH/tpm -p1 -r- -suN <$patch |& grep -q 'FAILED' \
      && print -P ":: %F{red}ERROR%f: failed to apply $patch"

    # Allow installed plugins to be automatically patched.
    local patch="$TMUX_PLUGIN_MANAGER_PATCH_DIR/tpm-patch-plugins.patch"
    patch -d $TMUX_PLUGIN_MANAGER_PATH/tpm -p1 -r- -suN <$patch |& grep -q 'FAILED' \
      && print -P ":: %F{red}ERROR%f: failed to apply $patch"

    # Patch the hardcoded helper function to reload the config file with our custom path.
    # See also https://github.com/tmux-plugins/tpm/issues/57.
    local patch="$TMUX_PLUGIN_MANAGER_PATCH_DIR/tpm-config.patch"
    patch -d $TMUX_PLUGIN_MANAGER_PATH/tpm -p1 -r- -suN <$patch |& grep -q 'FAILED' \
      && print -P ":: %F{red}ERROR%f: failed to apply $patch"

    # Install tmux plugins.
    print -P "%F{33}:: Installing tmux plugins...%f"
    $TMUX_PLUGIN_MANAGER_PATH/tpm/bin/install_plugins
  }
}

# TPM commands.
alias tpmi="$TMUX_PLUGIN_MANAGER_PATH/tpm/bin/install_plugins"
alias tpmu="$TMUX_PLUGIN_MANAGER_PATH/tpm/bin/update_plugins"
alias tpmc="$TMUX_PLUGIN_MANAGER_PATH/tpm/bin/clean_plugins"
