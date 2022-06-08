#
# Configuration of the tmux theme.
#

# Show the current directory instead of the current command in the window list.
set -g automatic-rename-format "#{=/-42/...;b:pane_current_path}#{?pane_dead,[dead],}"

# Show the pane title and set pane borders style.
set -g  pane-border-format "#{?pane_marked,#[reverse],}#{pane_index}═[#{pane_title}]#{?synchronize-panes,═[sync],}#{?pane_in_mode,═[#{pane_mode}],}"
set -g  pane-border-status top
set -g  pane-border-lines double

#
# Themepack configuration
#

set -g @themepack 'powerline/double/cyan'

# Color palette.
# Variants: orange=130, green=77
set -g @powerline-color-main-1 colour75
set -g @powerline-color-main-2 colour75
set -g @powerline-color-main-3 colour75
set -g @powerline-color-alt-1 colour11
set -g @powerline-color-alt-2 colour9
set -g @powerline-color-grey-1 colour233
set -g @powerline-color-grey-2 colour235
set -g @powerline-color-grey-3 colour238
set -g @powerline-color-grey-4 colour240
set -g @powerline-color-grey-5 colour243
set -g @powerline-color-grey-6 colour245
set -g @powerline-color-black-1 black

# Set the status-left contents.
set -g @themepack-status-left-area-left-format "#S"
set -g @themepack-status-left-area-middle-format "#I:#P"
set -g @themepack-status-left-area-right-format '#{=/-42/...:pane_current_command}'
# Set a bright color if the prefix is active.
set -g @powerline-status-left-area-left-bg "#{?client_prefix,#{@powerline-color-alt-1},#{@powerline-color-main-1}}"

# Set the status-right contents.
set -g @themepack-status-right-area-left-format '#($TMUX_COMMAND_DIR/status.zsh uptime)'
set -g @themepack-status-right-area-middle-format '#($TMUX_COMMAND_DIR/status.zsh username)'
set -g @themepack-status-right-area-right-format '#($TMUX_COMMAND_DIR/status.zsh hostname)'
# Set a bright color if the hostname is remote.
set -g @powerline-status-right-area-right-bg "#{?#{!=:#($TMUX_COMMAND_DIR/status.zsh hostname),#(hostnamectl hostname)},#{@powerline-color-alt-1},#{@powerline-color-main-1}}"
# Set a red bg color if the current username is 'root'.
set -g @powerline-status-right-area-middle-bg "#{?#{==:#($TMUX_COMMAND_DIR/status.zsh username),root},#{@powerline-color-alt-2},#{@powerline-color-grey-4}}"

# Set the max length of left and right status sections.
set -g @theme-status-left-length 100
set -g @theme-status-right-length 100

# Pad the window flags to keep a constant size with the most common flags (*/-).
set -g @themepack-window-status-current-format "#I:#W#{p1:window_flags}"
set -g @themepack-window-status-format "#I:#W#{p1:window_flags}"

# Use lighter colors for pane numbers and borders.
set -gF @theme-display-panes-active-colour "#{@powerline-color-main-3}"
set -gF @theme-display-panes-colour "#{@powerline-color-grey-5}"
set -gF @theme-pane-border-fg "#{@powerline-color-grey-5}"

# Match the terminal color for the current window.
set -gF @theme-window-status-current-fg "#{@powerline-color-main-3}"
set -gF @theme-window-status-current-bg "terminal"

# Use a pop-up color for messages and activity/silence notifications.
set -gF @theme-message-bg "#{@powerline-color-alt-1}"
set -gF @theme-message-command-bg "#{@powerline-color-alt-1}"
set -gF @powerline-color-activity-1 "#{@powerline-color-alt-1}"

# Set options from tmux 3.2 not yet integrated into themepack.
set -gF copy-mode-match-style "bg=#{@powerline-color-grey-6},fg=black"
set -gF copy-mode-current-match-style "bg=#{@powerline-color-main-1},fg=black"
set -gF copy-mode-mark-style "bg=#{@powerline-color-alt-2},fg=black"

# Set options from tmux 3.3 not yet integrated into themepack.
# set -g  fill-character '.'
set -g  pane-border-indicators colour
set -gF popup-border-style "bg=default,fg=#{@powerline-color-main-1}"
set -g  popup-border-lines double
