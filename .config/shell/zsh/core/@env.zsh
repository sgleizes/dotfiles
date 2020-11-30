#
# Core configuration module for zsh.
#

# Ensure that path arrays do not contain duplicates.
typeset -gU \
  CDPATH cdpath \
  FPATH fpath \
  MANPATH manpath \
  MODULE_PATH module_path \
  MAILPATH mailpath \
  PATH path

# User-based temporary directory.
export TMPDIR="/tmp/$USER"
[ ! -d "$TMPDIR" ] && command mkdir -p -m 700 "$TMPDIR"

# Set the pathname prefix for all zsh temporary files.
TMPPREFIX="${TMPDIR%/}/zsh"

# Disable control flow (^S/^Q) even for non-interactive shells.
# This is useful with e.g. `tmux new-session -s foo vim`
setopt no_flow_control
