#
# Autosuggestions configuration module for zsh.
#
# NOTE: Similarly to syntax-highlighting, this module wraps ZLE widgets and
# should be loaded after all widgets have been defined.
# For best results, syntax-highlighting should be loaded before so that
# highlighting is updated when the plugin updates the editor buffer.
#

# Abort if requirements are not met.
if (( ! $+functions[zinit] )) {
  return 1
}

# Disable highlighting for terminals with 8-color or less.
(( $terminfo[colors] <= 8 )) && ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=''

# Find suggestions from the history only.
ZSH_AUTOSUGGEST_STRATEGY=(history)
# Disable suggestions for large buffers.
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=42

# Do not rebind widgets on each precmd for performance.
# Use `_zsh_autosuggest_bind_widgets` to rebind if widgets are added or wrapped
# after the plugin has been loaded.
ZSH_AUTOSUGGEST_MANUAL_REBIND=y
# Fetch suggestions asynchronously.
ZSH_AUTOSUGGEST_USE_ASYNC=y

ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
  accept-line
  accept-and-hold
  accept-and-infer-next-history
  accept-line-and-down-history
  history-search-forward
  history-search-backward
  history-beginning-search-forward
  history-beginning-search-backward
  history-substring-search-up
  history-substring-search-down
  up-line-or-beginning-search
  down-line-or-beginning-search
  up-line-or-history
  down-line-or-history
  up-history
  down-history
  # BUG: The suggestion is not cleared when using compsys widgets.
  # https://github.com/zsh-users/zsh-autosuggestions/issues/531
  _most_recent_file
  _history-complete-older
  _history-complete-newer
  # BUG: Not working either
  run-help
  which-command
)

ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(
  orig-\*
  zle-\*
  beep
  run-help
  set-local-history
  which-command
  # BUG: This allows yank-pop to work properly but prevents updating the
  # suggestion after a yank, leaving the previous suggestion displayed.
  # https://github.com/zsh-users/zsh-autosuggestions/issues/526
  # yank
  # yank-pop
)

zinit ice wait lucid depth=1 atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
