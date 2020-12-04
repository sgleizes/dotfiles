#
# SSH configuration module for zsh.
#

# Return if requirements are not met.
if (( ! $+commands[ssh-agent] )); then
  return 1
fi

# Define the client hostname to forward to SSH connections.
: ${SSH_CLIENT_HOST:=$HOST}

# Define the default askpass program.
export SSH_ASKPASS="/usr/bin/ksshaskpass"

# Path to the SSH directory.
_ssh_dir="$HOME/.ssh"
# Path to the environment file if not set by another module.
_ssh_agent_env="${TMPDIR:-/tmp}/ssh-agent.env.$UID"
# Path to the persistent authentication socket.
_ssh_agent_sock="${TMPDIR:-/tmp}/ssh-agent.sock.$UID"

# Start ssh-agent if not started.
if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
  # Export environment variables.
  source $_ssh_agent_env 2>/dev/null

  # Start ssh-agent if not started.
  if ! ps -U $USER -o pid,ucomm | grep -q -- "${SSH_AGENT_PID:--1} ssh-agent"; then
    eval "$(ssh-agent | sed '/^echo /d' | tee $_ssh_agent_env)"
  fi
fi

# Create a persistent SSH authentication socket.
if [[ -S $SSH_AUTH_SOCK && $SSH_AUTH_SOCK != $_ssh_agent_sock ]]; then
  command ln -sf $SSH_AUTH_SOCK $_ssh_agent_sock
  export SSH_AUTH_SOCK="$_ssh_agent_sock"
fi

# Load identities.
if ssh-add -l 2>&1 | grep -q 'The agent has no identities'; then
  ssh_identities=($_ssh_dir/id_*(^AR))

  # From ssh-add(1):
  # If ssh-add needs a passphrase, it will read the passphrase from the current
  # terminal if it was run from a terminal. If ssh-add does not have a terminal
  # associated with it but DISPLAY and SSH_ASKPASS are set, it will execute the
  # program specified by SSH_ASKPASS and open an X11 window to read the
  # passphrase.
  [[ $DISPLAY && -x $SSH_ASKPASS ]] \
    && ssh-add -q $ssh_identities[@] </dev/null \
    || ssh-add -q $ssh_identities[@]
fi

unset _ssh_{dir,identities} _ssh_agent_{env,sock}
