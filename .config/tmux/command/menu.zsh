#!/bin/zsh
#
# Display a tmux context menu.
#

# Enable nested single-quotes using ''.
setopt rcquotes

# Session display menu.
function tmux_session_menu {
  local target
  [[ $MOUSE ]] && target=(-t= -xM -yW)

  echo display-menu $target[@] '-T "#[align=centre]#{session_name}" \
    "Next"     n "switch-client -n" \
    "Previous" p "switch-client -p" \
    "" \
    "Renumber" N "move-window -r" \
    "Rename"   n "command-prompt -I \"#S\" \"rename-session -- ''%%''\"" \
    "" \
    "New Session" s new-session \
    "New Window"  w new-window \
  '
}

# Window display menu.
function tmux_window_menu {
  local target=(-xW -yW)
  [[ $MOUSE ]] && target+=(-t=)

  echo display-menu $target[@] '-T "#[align=centre]#{window_index}:#{window_name}" \
    "#{?#{>:#{session_windows},1},,-}Swap Left" l "swap-window -t:-1" \
    "#{?#{>:#{session_windows},1},,-}Swap Right" r "swap-window -t:+1" \
    "#{?pane_marked_set,,-}Swap Marked" s "swap-window" \
    "" \
    "Kill"                        K "kill-window" \
    "Respawn"                     R "respawn-window -k" \
    "#{?pane_marked,Unmark,Mark}" m "select-pane -m" \
    "Rename"                      n "command-prompt -I \"#W\" \"rename-window -- ''%%''\""  \
    "" \
    "New After"  w "new-window -a" \
    "New At End" W "new-window" \
  '
}

# Pane display menu.
function tmux_pane_menu {
  local target=(-xP -yP)
  [[ $MOUSE ]] && target=(-t= -xM -yM)

  [[ $MOUSE ]] && local mouse_entries=' \
    "#{?mouse_word,Search For #[underscore]#{=/9/...:mouse_word},}" C-r "if -F \"#{?#{m/r:(copy|view)-mode,#{pane_mode}},0,1}\" \"copy-mode -t=\"; send -Xt= search-backward \"#{q:mouse_word}\"" \
    "#{?mouse_word,Type #[underscore]#{=/9/...:mouse_word},}"       C-y "copy-mode -q; send-keys -l -- \"#{q:mouse_word}\"" \
    "#{?mouse_word,Copy #[underscore]#{=/9/...:mouse_word},}"       c   "copy-mode -q; set-buffer -- \"#{q:mouse_word}\"" \
    "#{?mouse_line,Copy Line,}"                                     l   "copy-mode -q; set-buffer -- \"#{q:mouse_line}\"" \
  '

  echo display-menu $target[@] '-T "#[align=centre]#{pane_index}:#{pane_id}"' ${MOUSE:+$mouse_entries[@]} ' \
    "#{?#{m/r:(copy|view)-mode,#{pane_mode}},Go To Top,}"    < "send -X history-top" \
    "#{?#{m/r:(copy|view)-mode,#{pane_mode}},Go To Bottom,}" > "send -X history-bottom" \
    "" \
    "Horizontal Split" h "split-window -h" \
    "Vertical Split"   v "split-window -v" \
    "" \
    "#{?#{>:#{window_panes},1},,-}Swap Up"   u "swap-pane -U" \
    "#{?#{>:#{window_panes},1},,-}Swap Down" d "swap-pane -D" \
    "#{?pane_marked_set,,-}Swap Marked"      s "swap-pane" \
    "" \
    "Kill"    K "kill-pane" \
    "Respawn" R "respawn-pane -k" \
    "#{?pane_marked,Unmark,Mark}" m "select-pane -m" \
    "#{?#{>:#{window_panes},1},,-}#{?window_zoomed_flag,Unzoom,Zoom}" z "resize-pane -Z" \
  '
}

# Define the aliases for menu commands.
# NOTE: This approach is required for mouse menus, since the mouse target option (-t=)
# will only work when display-menu is invoked directly from a binding.
if [[ $TMUX_COMMAND_LOAD ]] {
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" display-menu-session="$(tmux_session_menu)"
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" display-menu-window="$(tmux_window_menu)"
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" display-menu-pane="$(tmux_pane_menu)"
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" display-menu-session-mouse="$(MOUSE=1 tmux_session_menu)"
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" display-menu-window-mouse="$(MOUSE=1 tmux_window_menu)"
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" display-menu-pane-mouse="$(MOUSE=1 tmux_pane_menu)"
}
