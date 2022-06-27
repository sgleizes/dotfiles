#
# Option monitoring module for zsh.
#
# NOTE: If ZOPT_AUTORUN is enabled, this module should be loaded last to ensure
# that no options are changed afterward.
#

# This parameter can be set to an empty value to disable running the guard automatically.
: ${ZOPT_AUTORUN=on}

# Path to the cache file for zsh options.
_ZOPT_CACHE="$ZCACHEDIR/zoptdump"
# List of patterns for unmonitored options.
_ZOPT_IGNORE=(
  # shell state options
  rcs
  interactive
  login
  privileged
  restricted
  shinstdin
  singlecommand
  zle
  # prompt options
  promptsubst # managed by active prompt theme
  promptcr    # powerlevel10k instant prompt support
  promptsp    # powerlevel10k instant prompt support
)

# List options with the no's in front removed for improved comprehension,
# i.e. `norcs off' becomes `rcs on'. It can take a list of option patterns
# to search for via egrep.
autoload -Uz allopt

# List/Search monitored options.
function zopt {
  allopt $@ | grep -vE ${(j:|:)_ZOPT_IGNORE}
}

# Check the current option states for changes against the last dump.
function zoptguard {
  if [[ ! -r $_ZOPT_CACHE ]]; then
    zoptdump
    return
  fi

  local dump diff
  dump=${(f)"$(zopt)"}
  diff=$(diff --color=always $_ZOPT_CACHE <(print $dump)) || {
    print -P ":: %F{yellow}WARNING%f: Options have changed since the last interactive run:"
    print $diff
    print ":: To accept the new options and suppress this warning, run 'zoptdump'"
    return 1
  }
}

# Accept the current option states, dumps to the cache file.
function zoptdump {
  zopt >|$_ZOPT_CACHE
}

# Return if autorun is not requested.
if [[ ! $ZOPT_AUTORUN ]]; then
  return 0
fi

# Run the guard immediately or asynchronously.
if (( ! $+functions[zi] )); then
  zoptguard
else
  # Handle asynchronous printing of the output.
  function _async_zoptguard {
    local out
    out=$(zoptguard)
    [[ $out ]] && { print; print $out; zle redisplay }
    unfunction _async_zoptguard
  }

  # Run after all external plugins have been loaded.
  zi ice wait'0c' lucid nocompile \
    id-as'guard/zopt' \
    nocd atload'_async_zoptguard'
  zi light z-shell/null
fi
