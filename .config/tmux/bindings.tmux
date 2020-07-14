#
# Configuration of tmux key bindings.
#

#
# Root
#

# Usual binding for closing an application, with autostart this will close the terminal.
bind -T root 'C-q' detach-client

# Clear both the screen and tmux history buffer.
bind -T root 'C-l' send-keys 'C-l' \; run 'sleep 0.1' \; clear-history

# Root bindings to enter copy-mode automatically.
bind -T root 'S-PPage' copy-mode -eu
bind -T root 'S-Up'    copy-mode -e \; send -X scroll-up

# Enable mouse support by default.
set -g mouse on

# Prevent status line scrolling from switching windows.
unbind -T root 'WheelUpStatus'
unbind -T root 'WheelDownStatus'

# Unbind pane display menu override.
unbind -T root 'M-MouseDown3Pane'

# Rebind mouse menu commands to custom aliases.
bind -T root 'MouseDown3StatusLeft' display-menu-session-mouse
bind -T root 'MouseDown3Status' display-menu-window-mouse
bind -T root 'MouseDown3Pane' {
  if -F -t= "#{||:#{mouse_any_flag},#{&&:#{pane_in_mode},#{?#{m/r:(copy|view)-mode,#{pane_mode}},0,1}}}" {
    select-pane -t=
    send -M
  } {
    display-menu-pane-mouse
  }
}

# Fix mouse wheel for applications using legacy scroll.
# See https://github.com/tmux/tmux/issues/1320#issuecomment-381952082.
bind -T root 'WheelUpPane' {
  if -Ft= "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -Mt=
  } {
    if -Ft= '#{alternate_on}' {
      send -t= -N 3 Up
    } {
      copy-mode -et=
    }
  }
}
bind -T root 'WheelDownPane' {
  if -Ft= "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -Mt=
  } {
    if -Ft= '#{alternate_on}' {
      send -t= -N 3 Down
    } {
      send -Mt=
    }
  }
}

# Paste the most recent buffer on middle click.
bind -T root 'MouseDown2Pane' {
  select-pane -t=
  if -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -M
  } {
    paste-buffer -p
  }
}

bind -T root 'DoubleClick1Pane' {
  select-pane -t=
  if -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -M
  } {
    copy-mode -H; send -X select-word; run -d0.3; send -X copy-pipe-and-cancel
  }
}
bind -T root 'TripleClick1Pane' {
  select-pane -t=
  if -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" {
    send -M
  } {
    copy-mode -H; send -X select-line; run -d0.3; send -X copy-pipe-and-cancel
  }
}

# Zoom/unzoom the selected pane.
bind -T root 'C-DoubleClick1Pane' resize-pane -Zt=

#
# Prefix
#

# Remove all default key bindings.
unbind -a -T prefix

# Set the prefix key to C-a.
unbind 'C-b'
set -g prefix 'C-a'
bind 'C-a' send-prefix

# Client operations.
bind -N 'Detach the current client'  'C-x' detach-client
bind -N 'Suspend the current client' 'M-x' suspend-client

# Client selection.
bind -N 'Select a client interactively' 'c' choose-client -Z

# Session operations.
bind -N 'Create a new session'       'N' command-prompt "new-session -s '%%'"
bind -N 'Rename the current session' 'S' command-prompt -I "#S" "rename-session -- '%%'"

# Session selection.
bind -N 'Select a session interactively' 's'    choose-tree -Zs
bind -N 'Select the next session'     -r 'Tab'  switch-client -n
bind -N 'Select the previous session' -r 'BTab' switch-client -p

# Window operations.
bind -N 'Create a new window'        'n'   new-window -c "#{pane_current_path}"
bind -N 'Rename the current window'  'W'   command-prompt -I "#W" "rename-window -- '%%'"
bind -N 'Kill the current window'    'K'   confirm-before -p "kill-window #W? (y/n)" kill-window
bind -N 'Respawn the current window' 'M-r' confirm-before -p "respawn-window #W? (y/n)" "respawn-window -k"
bind -N 'Move the current window the the left'  -r '<' swap-window -d -t -1
bind -N 'Move the current window the the right' -r '>' swap-window -d -t +1

# Window selection.
bind -N 'Select a window interactively'               'w'       choose-tree -Zw
bind -N 'Select the next window'                   -r 'NPage'   next-window
bind -N 'Select the previous window'               -r 'PPage'   previous-window
bind -N 'Select the next window with an alert'     -r 'M-NPage' next-window -a
bind -N 'Select the previous window with an alert' -r 'M-PPage' previous-window -a
bind -N 'Select window 1'  '1' select-window -t :=1
bind -N 'Select window 2'  '2' select-window -t :=2
bind -N 'Select window 3'  '3' select-window -t :=3
bind -N 'Select window 4'  '4' select-window -t :=4
bind -N 'Select window 5'  '5' select-window -t :=5
bind -N 'Select window 6'  '6' select-window -t :=6
bind -N 'Select window 7'  '7' select-window -t :=7
bind -N 'Select window 8'  '8' select-window -t :=8
bind -N 'Select window 9'  '9' select-window -t :=9
bind -N 'Select window 10' '0' select-window -t :=10

# Window splitting.
bind -N 'Split the current window horizontally' '-' split-window -h -c "#{pane_current_path}"
bind -N 'Split the current window vertically'   '_' split-window -v -c "#{pane_current_path}"

# Window layouts.
bind -N 'Select the next window layout'     -r '\' next-layout
bind -N 'Select the previous window layout' -r '|' previous-layout
bind -N 'Select the even-horizontal layout'  'M-1' select-layout even-horizontal
bind -N 'Select the even-vertical layout'    'M-2' select-layout even-vertical
bind -N 'Select the main-horizontal layout'  'M-3' select-layout main-horizontal
bind -N 'Select the main-vertical layout'    'M-4' select-layout main-vertical
bind -N 'Select the tiled layout'            'M-5' select-layout tiled
bind -N 'Spread the panes out evenly'        'C-e' select-layout -E

# Pane operations.
bind -N 'Mark the current pane' 'm' select-pane -m
bind -N 'Clear the marked pane' 'M' select-pane -M
bind -N 'Break the current pane into a new window'   'C-b' break-pane
bind -N 'Join the marked pane with the current pane' 'C-j' join-pane
bind -N 'Swap the current pane with the pane above'       -r 'o' swap-pane -U
bind -N 'Swap the current pane with the pane below'       -r 'O' swap-pane -D
bind -N 'Rotate the panes upward in the current window'   -r 'C-o' rotate-window -U
bind -N 'Rotate the panes downward in the current window' -r 'M-o' rotate-window -D
bind -N 'Kill the current pane'    'k'   confirm-before -p "kill-pane #P? (y/n)" "kill-pane"
bind -N 'Respawn the current pane' 'C-r' confirm-before -p "respawn-pane #P? (y/n)" "respawn-pane -k"

# Pane selection.
bind -N 'List and select a pane by index' 'p'   display-panes
bind -N 'Select the next pane'         -r 'C-p' select-pane -t :.+
bind -N 'Select the previous pane'     -r 'M-p' select-pane -t :.-
bind -N 'Select the pane above the active pane'           -r 'Up'    select-pane -U
bind -N 'Select the pane below the active pane'           -r 'Down'  select-pane -D
bind -N 'Select the pane to the left of the active pane'  -r 'Left'  select-pane -L
bind -N 'Select the pane to the right of the active pane' -r 'Right' select-pane -R

# Pane resizing.
bind -N 'Zoom the current pane'                 'Space'   resize-pane -Z
bind -N 'Resize the current pane up'         -r 'C-Up'    resize-pane -U
bind -N 'Resize the current pane down'       -r 'C-Down'  resize-pane -D
bind -N 'Resize the current pane left'       -r 'C-Left'  resize-pane -L
bind -N 'Resize the current pane right'      -r 'C-Right' resize-pane -R
bind -N 'Resize the current pane up by 5'    -r 'M-Up'    resize-pane -U 5
bind -N 'Resize the current pane down by 5'  -r 'M-Down'  resize-pane -D 5
bind -N 'Resize the current pane left by 5'  -r 'M-Left'  resize-pane -L 5
bind -N 'Resize the current pane right by 5' -r 'M-Right' resize-pane -R 5

# Buffer selection.
bind -N 'Paste the most recent buffer'  'v' paste-buffer -p
bind -N 'Select a buffer interactively' 'b' choose-buffer -Z {
  run -b "tmux show-buffer -b '%%' | $TMUX_CLIPBOARD"
}

# Enter backward search mode directly.
bind -N 'Search backward for a regular expression' '/' copy-mode \; send '?'

# Keymap information.
bind -N 'List key bindings'      '?' display-popup -w30% -h90% -KE -R "tmux list-keys -N | $PAGER"
bind -N 'Describe a key binding' '.' command-prompt -k -p "(key)" "list-keys -1N \"%%%\""

# Customize mode.
bind -N 'Customize options and bindings' ',' customize-mode -Z

# Status line commands.
bind -N 'Prompt for a command'      ':' command-prompt
bind -N 'Show status line messages' ';' show-messages

# Activity monitoring.
bind -N 'Toggle activity monitoring for the current window' '+' {
  set monitor-activity
  display 'monitor-activity #{?monitor-activity,on,off}'
}

# Silence monitoring.
bind -N 'Toggle silence monitoring for the current window' '=' {
  if -F '#{monitor-silence}' {
    set monitor-silence 0
    display 'monitor-silence off'
  } {
    command-prompt -p "(silence interval)" -I "2" {
      set monitor-silence '%%'
      display 'monitor-silence #{monitor-silence}'
    }
  }
}

# Pane synchronization.
bind -N 'Toggle pane synchronization in the current window' 'y' {
  set synchronize-panes
  display 'synchronize-panes #{?synchronize-panes,on,off}'
}

# Mouse support.
bind -N 'Toggle mouse support' 'M-m' {
  set mouse
  display 'mouse #{?mouse,on,off}'
}

# Display menus.
bind -N 'Show the session menu' 'M-S' display-menu-session
bind -N 'Show the window menu' 'M-W' display-menu-window
bind -N 'Show the pane menu' 'M-P' display-menu-pane

# Configuration management.
bind -N 'Edit the tmux configuration'   'e' edit-config
bind -N 'Reload the tmux configuration' 'r' reload

# Integration with https://github.com/facebook/pathpicker.
bind -N 'Run path-picker on the current pane visible contents' 'f' {
  capture-pane -J
  send C-j # push-line
  send "tmux show-buffer | fpp ; tmux delete-buffer" 'Enter'
}
bind -N 'Run path-picker on the current pane history' 'F' {
  capture-pane -J -S-
  send C-j # push-line
  send "tmux show-buffer | fpp ; tmux delete-buffer" 'Enter'
}

# Enter copy mode.
bind -N 'Enter copy mode' 'Enter' copy-mode

#
# Copy mode
#

# Remove all default key bindings.
unbind -a -T copy-mode
run -b 'tmux unbind -a -T copy-mode-vi 2>/dev/null || true' # ignore error if missing

# Copy the current selection to a new buffer or start one if none is active.
bind -T copy-mode 'Space' {
  if -F '#{||:#{selection_active},#{search_present}}' {
    send -X copy-pipe
  } {
    send -X begin-selection
  }
}

# Copy the current selection to a new buffer and exit copy mode, or start one if none is active.
bind -T copy-mode 'C-Space' {
  if -F '#{||:#{selection_active},#{search_present}}' {
    send -X copy-pipe-and-cancel
  } {
    send -X begin-selection
  }
}

# Clear the current selection or exit copy mode if none is active.
bind -T copy-mode 'Escape' {
  if -F '#{selection_active}' {
    send -X clear-selection
  } {
    send -X cancel
  }
}

# Exit copy mode.
bind -T copy-mode 'Enter'             send -X cancel
bind -T copy-mode 'q'                 send -X cancel
bind -T copy-mode 'C-c'               send -X cancel

# Move to beginning/end of line.
bind -T copy-mode 'C-s'               send -X start-of-line
bind -T copy-mode 'C-e'               send -X end-of-line
bind -T copy-mode 'Home'              send -X start-of-line
bind -T copy-mode 'End'               send -X end-of-line
bind -T copy-mode 'M-s'               send -X back-to-indentation

# Move the cursor around one character.
bind -T copy-mode 'Up'                send -X cursor-up
bind -T copy-mode 'Down'              send -X cursor-down
bind -T copy-mode 'Left'              send -X cursor-left
bind -T copy-mode 'Right'             send -X cursor-right

# Move forward/backward one word.
bind -T copy-mode 'M-Left'            send -X previous-word
bind -T copy-mode 'M-Right'           send -X next-word-end
bind -T copy-mode 'C-Left'            send -X previous-space
bind -T copy-mode 'C-Right'           send -X next-space-end

# Move forward/backward one block.
bind -T copy-mode 'M-Up'              send -X previous-paragraph
bind -T copy-mode 'M-Down'            send -X next-paragraph

# Move to the top/middle/bottom line of the current screen.
bind -T copy-mode 'M-h'               send -X top-line
bind -T copy-mode 'h'                 send -X middle-line
bind -T copy-mode 'M-H'               send -X bottom-line

# Scroll up/down the history buffer.
bind -T copy-mode 'C-Up'              send -X scroll-up
bind -T copy-mode 'C-Down'            send -X scroll-down
bind -T copy-mode 'S-Up'              send -X scroll-up
bind -T copy-mode 'S-Down'            send -X scroll-down
bind -T copy-mode 'M-S-Up'            send -X halfpage-up
bind -T copy-mode 'M-S-Down'          send -X halfpage-down
bind -T copy-mode 'NPage'             send -X page-down
bind -T copy-mode 'PPage'             send -X page-up
bind -T copy-mode 'S-NPage'           send -X page-down
bind -T copy-mode 'S-PPage'           send -X page-up

# Move to the top/bottom of the history buffer.
bind -T copy-mode 'g'                 send -X history-top
bind -T copy-mode 'G'                 send -X history-bottom

# Mark a line, swap the mark and the cursor position.
bind -T copy-mode 'x'                 send-keys -X set-mark
bind -T copy-mode 'X'                 send-keys -X jump-to-mark

# Go to a specific line in the history buffer.
bind -T copy-mode 'C-g'               command-prompt -p "(goto line)" "send -X goto-line \"%%%\""

# Search backward/forward for a regular expression.
# NOTE: For now the incremental search does not support regular expressions.
bind -T copy-mode '?'                 command-prompt -I "#{pane_search_string}" -p "(search up)" "send -X search-backward \"%%%\""
bind -T copy-mode '/'                 command-prompt -I "#{pane_search_string}" -p "(search down)" "send -X search-forward \"%%%\""
bind -T copy-mode 'n'                 send -X search-again
bind -T copy-mode 'N'                 send -X search-reverse

# Copy the current line to a new buffer.
# NOTE: This will not copy to the system clipboard, as copy-command is not used for these.
bind -T copy-mode 'C-k'               send -X copy-end-of-line
bind -T copy-mode 'M-C-k'             send -X copy-line

# Toggle rectangle selection mode.
bind -T copy-mode 'r'                 send -X rectangle-toggle

# Specify a repeat count for the next command.
bind -T copy-mode 'M-1'               send -N 1
bind -T copy-mode 'M-2'               send -N 2
bind -T copy-mode 'M-3'               send -N 3
bind -T copy-mode 'M-4'               send -N 4
bind -T copy-mode 'M-5'               send -N 5
bind -T copy-mode 'M-6'               send -N 6
bind -T copy-mode 'M-7'               send -N 7
bind -T copy-mode 'M-8'               send -N 8
bind -T copy-mode 'M-9'               send -N 9

# Mouse support.
bind -T copy-mode 'MouseDown1Pane'    select-pane
bind -T copy-mode 'MouseDrag1Pane'    select-pane \; send -X begin-selection
bind -T copy-mode 'WheelUpPane'       select-pane \; send -X -N 3 scroll-up
bind -T copy-mode 'WheelDownPane'     select-pane \; send -X -N 3 scroll-down
bind -T copy-mode 'DoubleClick1Pane'  select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe
bind -T copy-mode 'TripleClick1Pane'  select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe

# Avoid cancelling copy-mode if the pane history has been scrolled.
bind -T copy-mode 'MouseDragEnd1Pane' {
  if -F "#{scroll_position}" {
    send -X copy-pipe
  } {
    send -X copy-pipe-and-cancel
  }
}
