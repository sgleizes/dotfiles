#
# Restic configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[restic] || ! $+commands[kwalletcli] )); then
  return 1
fi

# Location of the restic repository.
export RESTIC_REPOSITORY='/run/media/maker/HOMEWORLD/Backups/Restic'

# Command to retrieve the password to the restic repository.
export RESTIC_PASSWORD_COMMAND='kwalletcli -f restic -e repository'

# Backup the whole system.
# This requires that the restic executable is assigned the capability to real all files:
# `setcap cap_dac_read_search=+ep $(which restic)`
alias backup-sys='restic --exclude={/dev,/media,/mnt,/proc,/run,/sys,/tmp,/var/tmp} backup /'

# Prune backups, keep only the last snapshot for each host and path.
alias backup-prune='restic forget --group-by host,paths --keep-last 1 --prune'
