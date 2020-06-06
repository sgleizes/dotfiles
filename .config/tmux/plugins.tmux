#
# Configuration of tmux plugins.
#

%if "$TMUX_PLUGIN_MANAGER_PATH"

# List of plugins to load.
# NOTE tmux-continuum should be loaded last, so that the environment is restored
# once all plugins have been loaded.
set -g @tpm_plugins {
  tmux-plugins/tpm
  jimeh/tmux-themepack
  Morantron/tmux-fingers
  tmux-plugins/tmux-logging
  tmux-plugins/tmux-resurrect
  tmux-plugins/tmux-continuum
}

#
# tmux-fingers
#

# Bindings and actions for tmux-fingers.
set -g @fingers-key 'C-f'
set -g @fingers-main-action  ':copy:'
set -g @fingers-ctrl-action  ':open:'
set -g @fingers-shift-action ':paste:'

# Colors for tmux-fingers.
set -g @fingers-hint-format                         '#[fg=yellow,bold]%s'
set -g @fingers-hint-format-nocompact               '#[fg=yellow,bold][%s]'
set -g @fingers-highlight-format                    '#[fg=yellow,nobold]%s'
set -g @fingers-highlight-format-nocompact          '#[fg=yellow,nobold]%s'
set -g @fingers-selected-hint-format                '#[fg=green,bold]%s'
set -g @fingers-selected-hint-format-nocompact      '#[fg=green,bold][%s]'
set -g @fingers-selected-highlight-format           '#[fg=green,nobold]%s'
set -g @fingers-selected-highlight-format-nocompact '#[fg=green,nobold]%s'

#
# tmux-logging
#

# Key bindings for tmux-logging.
set -g @logging_key 'l'
set -g @screen-capture-key 'M-l'
set -g @save-complete-history-key 'M-L'

# Path for tmux-logging saved files.
set -g @logging-path '#{pane_current_path}'
set -g @screen-capture-path '#{pane_current_path}'
set -g @save-complete-history-path '#{pane_current_path}'

# Formats for tmux-logging saved files.
set -g @logging-filename 'tmux-log.#{session_name}:#{window_index}:#{pane_index}.%Y-%m-%dT%H:%M:%S.log'
set -g @screen-capture-filename 'tmux-screen.#{session_name}:#{window_index}:#{pane_index}.%Y-%m-%dT%H:%M:%S.log'
set -g @save-complete-history-filename 'tmux-history.#{session_name}:#{window_index}:#{pane_index}.%Y-%m-%dT%H:%M:%S.log'

#
# tmux-resurrect
#

# Save directory for tmux-resurrect.
set -g @resurrect-dir "$XDG_DATA_HOME/tmux-resurrect"

# Capture and restore pane contents.
set -g @resurrect-capture-pane-contents on

# Key bindings for tmux-resurrect.
set -g @resurrect-save 'C-s'
set -g @resurrect-restore 'M-s'

# Hooks for tmux-resurrect.
set -g @resurrect-hook-pre-restore-all {
  # Prevent activity notifications while restoring.
  tmux set -g monitor-activity off
}
set -g @resurrect-hook-post-restore-all {
  # Restore automatic-rename after environment restore.
  # See https://github.com/tmux-plugins/tmux-resurrect/issues/57.
  for session_window in $(tmux list-windows -a -F '#{session_name}:#{window_index}'); do
    tmux set -t $session_window automatic-rename on
  done
  # Restore monitor-activity after a delay to avoid the spurious notifications.
  # NOTE If the session is started in the background, for some reason attaching after
  # monitor-activity is restored will still mark all windows with the activity flag.
  # This is the reason for the sensibly high delay.
  { sleep 15; tmux set -g monitor-activity on; } &
}

#
# tmux-continuum
#

# Restore the last saved environment automatically when tmux starts.
set -g @continuum-restore on
set -g @continuum-save-interval 10

#
# Load plugins
#

# Initialize the plugin manager (should be last in the config file).
run -b $TMUX_PLUGIN_MANAGER_PATH/tpm/tpm

%endif
