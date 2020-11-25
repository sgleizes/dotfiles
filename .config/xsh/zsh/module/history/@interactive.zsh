#
# History configuration module for zsh.
#

HISTFILE="$ZDATADIR/history"
HISTSIZE=10000
SAVEHIST=$HISTSIZE

setopt hist_verify      # do not execute immediately upon history expansion
setopt extended_history # save timestamp and duration to the history file
setopt share_history    # share history between all sessions

setopt hist_ignore_all_dups # remove old events when adding duplicates
setopt hist_ignore_space    # ignore commands starting with a space
setopt hist_save_no_dups    # remove older duplicates when writing the history file
setopt hist_no_functions    # remove function definitions from the history list
setopt hist_reduce_blanks   # remove superfluous blanks from commands

# Show statistics of the 20 most used commands.
function history-stats {
  history 1 \
    | awk '
      { cmds[$2]++; count++; }
      END {
        for (c in cmds) {
          print cmds[c] " " cmds[c]/count*100 "% " c;
        }
      }
    ' \
    | grep -v './' | column -c3 -s ' ' -t | sort -nr | nl | head -n20
}
