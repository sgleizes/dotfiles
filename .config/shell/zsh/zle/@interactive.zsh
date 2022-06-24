#
# ZLE configuration module for zsh.
#
# NOTE: This module should be loaded after the completion module.
# This is necessary so that the `menuselect` keymap and the bindable commands
# of the completion system are available. For more information about the
# latter, see the definition of _rebind_compsys_widgets below.
#

# NOTE: Reserved prefix keys:
# - ^X -> zle, emacs
# - ^O -> open terminal applications
# - ^A -> tmux
#
# Available Control keys: Q T V N

setopt no_beep         # do not fucking beep
setopt combining_chars # combine accents with the base character

# Return if requirements are not met.
if [[ $TERM == 'dumb' ]]; then
  return 1
fi

# Treat these characters as part of a word.
WORDCHARS='._-~?!#$%^&*()[]{}<>'

#
# Character highlighting
#

# See 'Character Highlighting' in zshzle(1).
zle_highlight=(
  isearch:underline
  region:standout
  special:standout
  suffix:bold
  paste:none # does not integrate well with syntax-highlighting
)

#
# Terminal application mode
#

# The terminal must be in application mode when ZLE is active for $terminfo
# values to be valid.
zmodload zsh/terminfo

# Enables terminal application mode when the editor starts,
# so that $terminfo values are valid.
function zle-line-init {
  if (( $+terminfo[smkx] )); then
    echoti smkx
  fi
}
zle -N zle-line-init

# Disables terminal application mode when the editor exits,
# so that other applications behave normally.
function zle-line-finish {
  if (( $+terminfo[rmkx] )); then
    echoti rmkx
  fi
}
zle -N zle-line-finish

#
# ZLE widgets
#

# Search history for a line beginning with the current line up to the cursor.
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Automatically quote pasted URLs when necessary.
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

# When the command is {sudo,git,openssl,...} <cmd>, get help on <cmd>.
unalias run-help
autoload -Uz run-help run-help-git run-help-ip run-help-openssl run-help-sudo
alias run-help='LESSOPEN= run-help' # avoid pre-processing zsh helpfiles

# Enhanced which-command that expands aliases.
unalias which-command
autoload -Uz which-command
zle -N which-command

# Easy zcalc answer reuse.
autoload -Uz zcalc-auto-insert
zle -N zcalc-auto-insert

# Allow command line editing in an external editor.
autoload -Uz edit-command-line
zle -N edit-command-line

# Replace a string in the current line.
autoload -Uz replace-string
autoload -Uz replace-string-again
zle -N replace-pattern replace-string
zle -N replace-pattern-again replace-string-again

# Duplicate previous words in the current line.
autoload -Uz copy-earlier-word
zle -N copy-earlier-word

# Insert the last word from the last history event at the cursor position.
# This only changes how the numeric argument is interpreted (array index).
function insert-last-word {
  zle .insert-last-word -- -1 ${NUMERIC:--1}
}
zle -N insert-last-word

# Insert the first word from the last history event at the cursor position.
function insert-first-word {
  zle .insert-last-word -- -1 ${NUMERIC:-1}
}
zle -N insert-first-word

# Expand .... to ../..
function expand-dot-to-parent-directory-path {
  if [[ $LBUFFER == *.. ]]; then
    LBUFFER+='/..'
  else
    LBUFFER+='.'
  fi
}
zle -N expand-dot-to-parent-directory-path

# Perform all types of shell expansions: history, alias, parameter,
# arithmetic, brace, filename.
function expand-all {
  zle _expand_alias
  zle expand-word
}
zle -N expand-all

# Insert 'sudo ' or 'sudoedit ' at the beginning of the line.
function prepend-sudo {
  if [[ $BUFFER == sudo\ * ]]; then
    BUFFER="${BUFFER#* }"
  elif [[ $BUFFER == (e|edit|$EDITOR)\ * ]]; then
    BUFFER="${BUFFER#* }"
    BUFFER="sudoedit $BUFFER"
  elif [[ $BUFFER == sudoedit\ * ]]; then
    BUFFER="${BUFFER#* }"
    BUFFER="edit $BUFFER"
  else
    BUFFER="sudo $BUFFER"
  fi
}
zle -N prepend-sudo

# Toggle the comment character at the start of the line. This is meant to work
# around a buggy implementation of pound-insert in zsh.
function pound-toggle {
  if [[ $BUFFER == '#'* ]]; then
    # Because of an oddity in how zsh handles the cursor when the buffer size
    # changes, we need to make this check before we modify the buffer and let
    # zsh handle moving the cursor back if it's past the end of the line.
    if [[ $CURSOR != $#BUFFER ]]; then
      (( CURSOR -= 1 ))
    fi
    BUFFER="${BUFFER:1}"
  else
    BUFFER="#$BUFFER"
    (( CURSOR += 1 ))
  fi
}
zle -N pound-toggle

# Reload the current shell, inserting and accepting a 'reload' command into the buffer.
function reload-shell {
  (( $+functions[reload] || $+aliases[reload] )) \
    && local cmd='reload' \
    || local cmd='exec zsh'

  BUFFER="$cmd"
  zle accept-line
}
zle -N reload-shell

# List key bindings.
function list-keys {
  bindkey | grep -v noop | "$PAGER"
}
zle -N list-keys

#
# Key bindings
#

# Create a new empty keymap.
keymap=custom
bindkey -N $keymap
bindkey -A $keymap main

# Delete unused keymaps.
bindkey -D vicmd viins viopp visual

# Use human-friendly identifiers.
typeset -gA keys
keys=(
  'Control'          '^'
  'Alt'              '\e'
  # defaults with konsole
  'Backspace'        "$terminfo[kbs]"
  'ControlBackspace' '^H'
  'Enter'            "$terminfo[cr]"
  'ShiftEnter'       "$terminfo[kent]"
  'ShiftPageUp'      "$terminfo[kPRV]"
  'ShiftPageDown'    "$terminfo[kNXT]"
  'ScrollUp'         "$terminfo[kri]"
  'ScrollDown'       "$terminfo[kind]"
  # terminfo(5)
  'F1'               "$terminfo[kf1]"
  'F2'               "$terminfo[kf2]"
  'F3'               "$terminfo[kf3]"
  'F4'               "$terminfo[kf4]"
  'F5'               "$terminfo[kf5]"
  'F6'               "$terminfo[kf6]"
  'F7'               "$terminfo[kf7]"
  'F8'               "$terminfo[kf8]"
  'F9'               "$terminfo[kf9]"
  'F10'              "$terminfo[kf10]"
  'F11'              "$terminfo[kf11]"
  'F12'              "$terminfo[kf12]"
  'Home'             "$terminfo[khome]"
  'End'              "$terminfo[kend]"
  'Insert'           "$terminfo[kich1]"
  'Delete'           "$terminfo[kdch1]"
  'PageUp'           "$terminfo[kpp]"
  'PageDown'         "$terminfo[knp]"
  'Up'               "$terminfo[kcuu1]"
  'Left'             "$terminfo[kcub1]"
  'Down'             "$terminfo[kcud1]"
  'Right'            "$terminfo[kcuf1]"
  'BackTab'          "$terminfo[kcbt]"
  # user_caps(5)
  'ControlUp'        "$terminfo[kUP5]"
  'ControlDown'      "$terminfo[kDN5]"
  'ControlRight'     "$terminfo[kRIT5]"
  'ControlLeft'      "$terminfo[kLFT5]"
  'ControlDelete'    "$terminfo[kDC5]"
  'ControlPageUp'    "$terminfo[kPRV5]"
  'ControlPageDown'  "$terminfo[kNXT5]"
  'AltUp'            "$terminfo[kUP3]"
  'AltDown'          "$terminfo[kDN3]"
  'AltRight'         "$terminfo[kRIT3]"
  'AltLeft'          "$terminfo[kLFT3]"
  'AltDelete'        "$terminfo[kDC3]"
  'AltPageUp'        "$terminfo[kPRV3]"
  'AltPageDown'      "$terminfo[kNXT3]"
)

# Source TERM and HOST specific keyboard overrides.
# These files can be generated using `zkbd`, see zshcontrib(1).
# The files will be generated in `$ZDOTDIR/.zkbd` and should be moved to the
# XDG path below, following the different naming scheme based on TERM/HOST.
# For consistency, the generated files needs to be edited to use the parameter
# name `keys` instead of `key`. Specific overrides for keys not supported by
# zkbd but referenced above can also be added.
function _load_zkbd_config {
  local zkbd_config="$ZDATADIR/zkbd/$TERM.${1//-/.}"
  [[ -r $zkbd_config ]] && source $zkbd_config
}

# Load the configuration of the SSH client host or the current host if that exists.
[[ "$SSH_CLIENT_HOST" ]] \
  && _load_zkbd_config $SSH_CLIENT_HOST \
  || _load_zkbd_config $HOST \
  || _load_zkbd_config default

# Set empty $keys values to an invalid UTF-8 sequence to induce silent
# bindkey failure.
for key in ${(k)keys[@]}; do
  if [[ ! $keys[$key] ]]; then
    keys[$key]='�'
  fi
done

# In emacs mode, some unbound keys insert a tilde in the buffer. Bind these
# keys in the main keymap to a noop to avoid this behavior.
function _zle-noop { ; }
zle -N _zle-noop
local -a unbound_keys
unbound_keys=(
  $keys[F1]
  $keys[F2]
  $keys[F3]
  $keys[F4]
  $keys[F5]
  $keys[F6]
  $keys[F7]
  $keys[F8]
  $keys[F9]
  $keys[F10]
  $keys[F11]
  $keys[F12]
  $keys[ScrollUp]
  $keys[ScrollDown]
  $keys[PageUp]
  $keys[PageDown]
  $keys[ControlPageUp]
  $keys[ControlPageDown]
  $keys[AltPageUp]
  $keys[AltPageDown]
  $keys[ShiftPageUp]
  $keys[ShiftPageDown]
)
for key in $unbound_keys[@]; do
  bindkey "$key" _zle-noop
done

#
# Key bindings
#

# Set all characters to self-insert by default.
bindkey -R ' '-'~' self-insert         # printable ascii characters
bindkey -R '\M-^@'-'\M-^?' self-insert # multibyte characters

# Prevent rebound characters to alter the behavior of contextual keymaps.
bindkey -M isearch -R ' '-'~' self-insert
bindkey -M isearch -R '\M-^@'-'\M-^?' self-insert
bindkey -M command -R ' '-"~" self-insert
bindkey -M command -R '\M-^@'-'\M-^?' self-insert

# Start a new numeric argument, or add to the current one.
for key in "$keys[Alt]"{0-9}; do
  bindkey "$key" digit-argument
done
# Changes the sign of the following argument
bindkey "$keys[Alt]-" neg-argument

#
# Key bindings - Movement
#

# Move to beginning/end of line.
for key in "$keys[Control]A" "$keys[Home]"; do
  bindkey "$key" beginning-of-line
done
for key in "$keys[Control]E" "$keys[End]"; do
  bindkey "$key" end-of-line
done

# Move forward/backward one character.
bindkey "$keys[Left]" backward-char
bindkey "$keys[Right]" forward-char

# Move forward/backward one word.
bindkey "$keys[ControlLeft]" emacs-backward-word
bindkey "$keys[ControlRight]" emacs-forward-word
bindkey "$keys[AltLeft]" vi-backward-word
bindkey "$keys[AltRight]" vi-forward-word

# Search previous/next character.
bindkey "$keys[Alt]/" vi-find-next-char
bindkey "$keys[Alt]?" vi-find-prev-char
bindkey "$keys[Alt]$keys[Control]_" vi-repeat-find # Control + Alt + /

# Move to matching bracket.
bindkey "$keys[Alt]]" vi-match-bracket

#
# Key bindings - History Control
#

# Search history for a line beginning with the current line up to the cursor.
bindkey "$keys[Up]" up-line-or-beginning-search
bindkey "$keys[Down]" down-line-or-beginning-search

# Search history for a line beginning with the first word in the buffer.
bindkey "$keys[AltUp]" history-search-backward
bindkey "$keys[AltDown]" history-search-forward

# Move to the previous/next event in the history list.
bindkey "$keys[ControlUp]" up-history
bindkey "$keys[ControlDown]" down-history

# Use the incremental *pattern* search variant.
bindkey "$keys[Control]R" \
  history-incremental-pattern-search-backward
bindkey "$keys[Alt]$keys[Control]R" \
  history-incremental-pattern-search-forward

# Toggle visiting of imported lines as well as local lines (on by default).
bindkey "$keys[Control]X$keys[Control]L" set-local-history

# Insert the first/last word from the previous history event.
bindkey "$keys[Alt]>" insert-first-word
bindkey "$keys[Alt]." insert-last-word

#
# Key bindings - Modifying text
#

# Delete the character under the cursor, or list possible completions for the
# current word.
for key in "$keys[Control]D" "$keys[Delete]"; do
  bindkey "$key" delete-char-or-list
done

# Delete the character behind the cursor.
bindkey "$keys[Backspace]" backward-delete-char

# Kill/Delete the curent word.
for key in "$keys[Alt]D" "$keys[ControlDelete]"; do
  bindkey "$key" kill-word
done
for key in "$keys[Alt]d" "$keys[AltDelete]"; do
  bindkey "$key" delete-word
done

# Kill/Delete the word behind the cursor.
bindkey "$keys[ControlBackspace]" backward-kill-word
for key in "$keys[Control]W" "$keys[Alt]$keys[Backspace]"; do
  bindkey "$key" backward-delete-word
done

# Kill from the cursor to the end of the line.
bindkey "$keys[Control]K" kill-line
# Kill from the beginning of the line to the cursor position.
for key in "$keys[Alt]k" "$keys[Alt]$keys[ControlBackspace]"; do
  bindkey "$key" backward-kill-line
done
# Kill the current line.
bindkey "$keys[Alt]$keys[Control]K" kill-whole-line
# Kill the entire buffer.
bindkey "$keys[Control]X$keys[Control]K" kill-buffer

# Insert the contents of the kill buffer at the cursor position.
bindkey "$keys[Control]Y" yank
# Remove the text just yanked, rotate the kill-ring and yank the new top.
bindkey "$keys[Alt]y" yank-pop

# Push the current buffer onto the buffer stack and clear the buffer.
bindkey "$keys[Control]U" push-line-or-edit
# Pop the top line off the buffer stack and insert it at the cursor position.
bindkey "$keys[Control]B" get-line

# Duplicate previous words in the current line.
for key in "$keys[Control]P" "$keys[Alt]p"; do
  bindkey "$key" copy-earlier-word
done

# Quote the current line.
bindkey "$keys[Alt]'" quote-line

# Convert the current word to all uppercase/lowercase and move past it.
bindkey "$keys[Control]Xu" up-case-word
bindkey "$keys[Control]Xl" down-case-word

# Toggle between overwrite mode and insert mode.
bindkey "$keys[Insert]" overwrite-mode

# Edit command in an external editor.
bindkey "$keys[Control]Xe" edit-command-line

# Replace a string in the current line.
bindkey "$keys[Alt]r" replace-pattern
bindkey "$keys[Alt]R" replace-pattern-again

# Insert 'sudo ' at the beginning of the line.
bindkey "$keys[Control]X$keys[Control]S" prepend-sudo

# Toggle comment at the start of the line. Note that we use pound-toggle which
# is similar to pount insert, but meant to work around some issues.
bindkey "$keys[Alt];" pound-toggle

# List key bindings.
bindkey "$keys[Control]X?" list-keys

#
# Key bindings - Completion
#

# Attempt completion on the current word.
# If completion styles are not set up to perform expansion as well as
# completion, this should be changed to expand-or-complete.
bindkey "$keys[Control]I" complete-word # Tab

# Move to the previous entry during menu completion.
bindkey "$keys[BackTab]" reverse-menu-complete

# Override bindings in the menuselect keymap.
# The completion module should be loaded before the editor, so that the
# zsh/complist module is loaded and the menuselect keymap available.
if bindkey -l menuselect >/dev/null 2>&1; then
  # Move the mark to the first/last line of the next/previous group of matches.
  bindkey -M menuselect "$keys[PageDown]" vi-forward-blank-word
  bindkey -M menuselect "$keys[PageUp]" vi-backward-blank-word

  # Move the mark to the first/last line.
  bindkey -M menuselect "$keys[AltPageUp]" beginning-of-history
  bindkey -M menuselect "$keys[AltPageDown]" end-of-history

  # Start incremental searches in the list of completions displayed.
  bindkey -M menuselect "$keys[Control]R" \
    history-incremental-search-forward
  bindkey -M menuselect "$keys[Alt]$keys[Control]R" \
    history-incremental-search-backward

  # Avoid showing previous autosuggestion when leaving the menu using a space.
  bindkey -M menuselect ' ' accept-line
  # Accept the current menu item and continue selection.
  bindkey "$keys[Control]@" accept-and-hold # Control + Space
fi

# Expand ... to ../.. (except for special keymaps).
bindkey '.' expand-dot-to-parent-directory-path

# Expand history on space.
bindkey ' ' magic-space

# Expand command name to full path.
bindkey "$keys[Alt]e" expand-cmd-path

# Expand whatever is under the cursor.
bindkey "$keys[Alt] " expand-all

#
# Key bindings - Misc
#

# Finish editing the buffer and execute it as a shell command.
bindkey "$keys[Control]J" accept-line # Line Feed
bindkey "$keys[Control]M" accept-line # Carriage Return
# Push the contents of the buffer on the buffer stack and execute it.
# During menu completion, accept the currently inserted match and continue
# selection allowing to select the next match to insert into the line.
bindkey "$keys[ShiftEnter]" accept-and-hold
# Execute the current line and push the next history event on the buffer stack.
bindkey "$keys[Alt]$keys[Enter]" accept-line-and-down-history

# Clear the screen and redraw the prompt.
bindkey "$keys[Control]L" clear-screen
# Abort the current editor line or function.
bindkey "$keys[Control]G" send-break

# Incrementally undo the last text modification.
bindkey "$keys[Alt]u" undo
# Incrementally redo undone text modifications.
bindkey "$keys[Alt]U" redo

# Attempt spelling correction on the current word.
bindkey "$keys[Alt]s" spell-word

# Show the manual for the current command/builtin.
bindkey "$keys[Alt]h" run-help
# Show how the current command would be interpreted by the shell.
bindkey "$keys[Alt]H" which-command

# Reload the current shell.
bindkey "$keys[Control]Xr" reload-shell

# Easy zcalc answer reuse (except for special keymaps).
bindkey '+' zcalc-auto-insert
bindkey '\-' zcalc-auto-insert
bindkey '*' zcalc-auto-insert
bindkey '/' zcalc-auto-insert

# Support the bracketed-paste sequence generated by the terminal emulator when
# text is pasted.
bindkey '^[[200~' bracketed-paste

# ZLE testing.
bindkey "$keys[Control]X'" quoted-insert
bindkey "$keys[Control]X." describe-key-briefly
bindkey "$keys[Control]X/" where-is
bindkey "$keys[Alt]x" execute-named-cmd
bindkey "$keys[Alt]X" execute-last-named-cmd

#
# Key bindings - Applications
#

# Run htop.
if (( $+commands[htop] )); then
  function open-htop {
    exec </dev/tty
    htop
    zle redisplay
  }
  zle -N open-htop
  bindkey "$keys[Control]Oh" open-htop
fi

# Run btop.
if (( $+commands[btop] )); then
  function open-btop {
    exec </dev/tty
    btop +t
    zle redisplay
  }
  zle -N open-btop
  bindkey "$keys[Control]O$keys[Control]H" open-btop
fi

#
# Key bindings - Completion system bindable commands
#

# Unbind the given widgets from all their bound keys in the main keymap.
# Usage: _zle_unbind_widgets <widgets>...
function _zle_unbind_widgets {
  if (( $# == 0 )); then
    return 1
  fi

  local key widget
  local bound_keys=("${(f)$(bindkey | grep -E "${(j:|:)@}")}")
  for key widget in ${(z)bound_keys}; do
    [[ "$widget" ]] && bindkey -r "${(Q)key}"
  done
}

# Rebind the bindable commands added by the completion system.
# These bindings are added when executing `compinit`, which has not necessarily
# been done at this time depending on the configuration setup.
#
# Specifically, zinit provides its own compdef function and allows `compinit`
# to run asynchronously after the first prompt is shown.
# This function is thus meant to be called after the call to compinit.
function _rebind_compsys_widgets {
  # Keep the default binding for:
  # _complete_help, _next_tags,
  # _correct_word, _correct_filename

  # Unbind unused, obsolete or rebound widgets.
  local unbound_widgets=(
    # unused
    _bash_list-choices
    _bash_complete-word
    _read_comp
    _complete_tag
    _most_recent_file
    # superseeded by delete-char-or-list
    _list_expansions
    # superseeded by expand-all
    _expand_alias _expand_word
    # rebound to other keys
    _complete_debug
    _history-complete-newer
    _history-complete-older
  )
  _zle_unbind_widgets $unbound_widgets

  # Perform and trace completion.
  bindkey "$keys[Control]XH" _complete_debug

  # Complete words from the shell's command history.
  bindkey "$keys[Alt]<" _history-complete-newer
  bindkey "$keys[Alt]," _history-complete-older

  unfunction _rebind_compsys_widgets
}

# Rebind widgets immediately if compinit has been loaded.
# During the initial zinit run, plugins are loaded synchronously, so compinit
# is already available in this case. We check this as we want zinit to download
# the null repository anyway so that it doesn't show up during the second load.
if (( $+functions[compinit] && ! $+functions[zinit] )); then
  _rebind_compsys_widgets
else
  # Postpone rebinding after the asynchronous compinit.
  zinit ice wait lucid nocompile \
    id-as'hack/rebind-compsys-widgets' \
    nocd atload'_rebind_compsys_widgets'
  zinit light zdharma/null
fi

unset key{,map}
