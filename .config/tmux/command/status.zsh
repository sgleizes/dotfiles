#!/bin/zsh
#
# Expose commands for the tmux status line.
#

# Define the aliases for status commands.
if [[ $TMUX_COMMAND_LOAD ]]; then
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" status-hostname="run '$0 hostname'"
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" status-username="run '$0 username'"
  tmux set "command-alias[$(( TMUX_COMMAND_LOAD++ ))]" status-uptime="run '$0 uptime'"
  return
fi

# Print the current user and command of the given tty.
function tty_info {
  tty="${1##/dev/}"
  ps -t "$tty" -o user=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -o pid= -o ppid= -o command= | awk '
    NR > 1 && ((/ssh/ && !/-W/) || !/ssh/) {
      user[$2] = $1; parent[$2] = $3; child[$3] = $2; for (i = 4 ; i <= NF; ++i) command[$2] = i > 4 ? command[$2] FS $i : $i
    }
    END {
      for (i in parent)
      {
        j = i
        while (parent[j])
          j = parent[j]

        if (!(i in child) && j != 1)
        {
          print i, user[i], command[i]
          exit
        }
      }
    }
  '
}

# Print given command arguments if the command is SSH or MOSH.
function ssh_or_mosh_args {
  args=$(printf '%s' "$1" \
    | awk '/ssh/ && !/vagrant ssh/ && !/autossh/ && !/-W/ { $1=""; print $0; exit }')
  [[ ! "$args" ]] && args=$(printf '%s' "$1" | grep 'mosh-client' \
    | sed -E -e 's/.*mosh-client -# (.*)\|.*$/\1/' -e 's/-[^ ]*//g' -e 's/\d:\d//g')

  printf '%s' "$args"
}

# Display the local or remote username of the current tmux pane.
function status_username {
  tty=${1:-$(tmux display -p '#{pane_tty}')}
  tty_info=$(tty_info "$tty")
  command=$(printf '%s' "$tty_info" | cut -d' ' -f3-)

  ssh_or_mosh_args=$(ssh_or_mosh_args "$command")
  if [[ $ssh_or_mosh_args ]]; then
    username=$(ssh -G ${=ssh_or_mosh_args} 2>/dev/null | awk 'NR > 2 { exit } ; /^user / { print $2 }')
    [[ ! $username ]] && username=$( \
      ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%username%% %r >&2'" ${=ssh_or_mosh_args} 2>&1 \
        | awk '/^%username% / { print $2; exit }')
  else
    username=$(printf '%s' "$tty_info" | cut -d' ' -f2)
  fi

  printf '%s\n' "$username"
}

# Display the local or remote hostname of the current tmux pane.
function status_hostname {
  tty=${1:-$(tmux display -p '#{pane_tty}')}
  tty_info=$(tty_info "$tty")
  command=$(printf '%s' "$tty_info" | cut -d' ' -f3-)

  ssh_or_mosh_args=$(ssh_or_mosh_args "$command")
  if [[ $ssh_or_mosh_args ]]; then
    hostname=$(ssh -G ${=ssh_or_mosh_args} 2>/dev/null | awk 'NR > 2 { exit } ; /^hostname / { print $2 }')
    [[ ! "$hostname" ]] && hostname=$( \
      ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%hostname%% %h >&2'" ${=ssh_or_mosh_args} 2>&1 \
        | awk '/^%hostname% / { print $2; exit }')
    echo "$hostname" | awk '\
    { \
      if ($1~/^[0-9.:]+$/) \
        print $1; \
      else \
        split($1, a, ".") ; print a[1] \
    }'
  elif (( $+commands[hostname] )); then
    command hostname
  else
    command hostnamectl hostname
  fi
}

# Display the local or remote uptime of the current tmux pane.
function status_uptime {
  tty=${1:-$(tmux display -p '#{pane_tty}')}
  tty_info=$(tty_info "$tty")
  command=$(printf '%s' "$tty_info" | cut -d' ' -f3-)

  ssh_or_mosh_args=$(ssh_or_mosh_args "$command")
  if [[ $ssh_or_mosh_args ]]; then
    printf '-remote-' # too expensive to fetch
    return
  fi

  boot=0
  now=$(cut -d' ' -f1 </proc/uptime)

  awk -v boot="$boot" -v now="$now" '
    BEGIN {
      uptime = now - boot
      y = int(uptime / 31536000)
      dy = int(uptime / 86400) % 365
      d = int(uptime / 86400)
      h = int(uptime / 3600) % 24
      m = int(uptime / 60) % 60
      s = int(uptime) % 60

      OFS = ""
      print (y!=0)?y"y ":"", (dy!=0)?dy"d ":"", (h!=0)?h"h ":"", (m!=0)?m"m":""
    }
  '
}

while (( $# > 0 )); do
  case $1 in
    hostname) status_hostname ;;
    username) status_username ;;
    uptime) status_uptime ;;
  esac
  shift
done
