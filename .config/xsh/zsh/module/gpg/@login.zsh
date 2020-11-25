#
# GPG configuration module for zsh.
#
# NOTE: To use gpg-agent as a drop-in replacement for ssh-agent,
# add `enable-ssh-support` to `~/.gnupg/gpg-agent.conf`.
# In this case loading the ssh module is not necessary, it is loaded as a dependency.
#

# Return if requirements are not met.
if (( ! $+commands[gpg-agent] )) {
  return 1
}

# Default path to gpg-agent configuration.
_gpg_agent_conf="${GNUPGHOME:-$HOME/.gnupg}/gpg-agent.conf"

# Start gpg-agent if not started.
gpg-connect-agent /bye &>/dev/null

# Use gpg-agent in place of ssh-agent.
if { grep '^enable-ssh-support' "$_gpg_agent_conf" &>/dev/null } {
  unset SSH_AGENT_PID
  # This test is for the case where the agent is started as `gpg-agent --daemon /bin/sh`,
  # in which case the shell inherits the SSH_AUTH_SOCK variable from the parent.
  if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" != $$ ]] {
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  }

  # Load the SSH module for additional processing.
  xsh load ssh login
}

unset _gpg_agent_conf
