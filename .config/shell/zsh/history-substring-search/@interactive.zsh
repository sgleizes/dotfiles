#
# History substring search configuration module for zsh.
#
# NOTE: Similarly to syntax-highlighting, this module wraps ZLE widgets and
# should be loaded after all widgets have been defined.
# For best results, syntax-highlighting should be loaded before so that
# highlighting is updated when the plugin updates the editor buffer.
#

# Abort if requirements are not met.
if (( ! $+functions[zi] )); then
  return 1
fi

# Configure zsh-history-substring-search.
# This is provided as a function since the plugin is loaded asynchronously
# and does not support overriding the defaults.
function _configure_history_substring_search {
  # Half case-sensitive: lower matches upper, upper does not match lower.
  HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS=l

  # Use less flashy colors.
  if (( $terminfo[colors] >= 256 )); then
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=62,fg=white,bold'
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=88,fg=white,bold'
  elif (( $terminfo[colors] >= 8 )); then 
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=blue,fg=white,bold'
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
  fi

  # Rebind up/down keys to use the loaded widgets.
  bindkey "$keys[Up]" history-substring-search-up
  bindkey "$keys[Down]" history-substring-search-down

  unfunction _configure_history_substring_search
}

zi ice wait lucid depth=1 atload'_configure_history_substring_search'
zi light zsh-users/zsh-history-substring-search
