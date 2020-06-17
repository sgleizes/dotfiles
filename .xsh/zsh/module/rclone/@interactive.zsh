#
# Rclone configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[rclone] || ! $+commands[kwalletcli] )) {
  return 1
}

# Command to retrieve the password to the rclone configuration.
export RCLONE_PASSWORD_COMMAND='kwalletcli -f rclone -e config'

# Use recursive listing for remoted supporting it.
# Uses more memory but fewer transactions.
export RCLONE_FAST_LIST='true'

# Perform renaming server-side if size and hash matches.
export RCLONE_TRACK_RENAMES='true'
