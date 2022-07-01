#
# Keymap monitoring module for zsh.
#
# NOTE: If ZKEY_AUTORUN is enabled, this module should be loaded last to ensure
# that no keymaps are changed afterward.
#

# This parameter can be set to an empty value to disable running the guard automatically.
: ${ZKEY_AUTORUN=on}

# Path to the cache files for the main keymap.
_ZKEY_CACHE="$ZCACHEDIR/zkeydump-$TERM"
# List of patterns for unmonitored keys.
_ZKEY_IGNORE=(
  noop
)

# List/Search monitored keys.
function zkey {
  bindkey $1 | grep -vE ${(j:|:)_ZKEY_IGNORE} | LC_ALL=C sort
}

# Check the main keymap for changes against the last dump.
function zkeyguard {
  if [[ ! -r $_ZKEY_CACHE ]]; then
    [[ $TERM && $TERM != 'dumb' ]] && zkeydump
    return
  fi

  local dump diff
  dump=${(f)"$(zkey)"}
  diff=$(diff --color=always $_ZKEY_CACHE <(print -r $dump)) || {
    print -P ":: %F{yellow}WARNING%f: Key bindings have changed since the last interactive run:"
    print -r $diff
    print ":: To accept the new keymap and suppress this warning, run 'zkeydump'"
    return 1
  }
}

# Accept the current keymap, dumps to the cache file.
function zkeydump {
  zkey >|$_ZKEY_CACHE
}

# Return if autorun is not requested.
if [[ ! $ZKEY_AUTORUN ]]; then
  return 0
fi

# Run the guard immediately or asynchronously.
if (( ! $+functions[zi] )); then
  zkeyguard
else
  # Handle asynchronous printing of the output.
  function _async_zkeyguard {
    local out
    out=$(zkeyguard)
    [[ $out ]] && { print; print -r $out; zle redisplay }
    unfunction _async_zkeyguard
  }

  # Run after all external plugins have been loaded.
  zi light-mode wait'0c' lucid for \
    id-as'guard/zkey' \
    atload'_async_zkeyguard' nocompile nocd \
    @z-shell/null
fi
