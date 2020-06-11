#
# Yadm configuration module for zsh.
#
# NOTE: This module defines an additional git wrapper command and as such,
# it should be loaded before the git module.
#

# Abort if requirements are not met.
if (( ! $+commands[yadm] )) {
  return 1
}

# Register yadm as a git wrapper command, see the git module.
_git_wrapper_commands+=(yadm)

# Add function dir to fpath for completion support.
autoload_dir ${0:h}/function

#
# Worktree management
#
# Create the worktree for the master branch with:
# `yadm worktree add <path> master`

# Synchronize the master worktree with local changes in HOME.
# This will synchronize files which are tracked on the master branch, and
# all staged files in the main worktree.
function yadm-sync {
  local main master
  local rsync_opts=(-axu --no-implied-dirs --ignore-missing-args --info=name)

  # List of files which are tracked on both branches and should not be auto-synced.
  local sync_ignore=(
    .config/yadm/gitconfig
    .config/yadm/unstable
  )

  main="$(yadm rev-parse --show-toplevel)"
  if [[ ! "$main" ]] {
    print -P ':: %F{red}ERROR%f: main worktree does not exist'
    return 1
  }

  master="$(yadm worktree list | grep master | awk '{print $1}')"
  if [[ ! "$master" ]] {
    print -P ':: %F{red}ERROR%f: master worktree does not exist'
    return 1
  }

  # Sync files which are tracked on the master branch.
  rsync $rsync_opts[@] --files-from=<(git -C $master ls-files | grep -v ${(j:|:)sync_ignore}) $main $master
  # Sync staged files from the main worktree.
  rsync $rsync_opts[@] --files-from=<(yadm diff --name-only --cached) $main $master
}

# This function is intended to be used from the 'desktop' branch to merge
# the changes committed on the master worktree. It behaves similarly to yadm-sync,
# stashing files which are tracked on the master branch and all staged files in the
# main worktree.
function yadm-merge {
  local master

  master="$(yadm worktree list | grep master | awk '{print $1}')"
  if [[ ! "$master" ]] {
    print -P ':: %F{red}ERROR%f: master worktree does not exist'
    return 1
  }

  yadm stash push -- $(git -C $master ls-files) $(yadm diff --name-only --cached)
  yadm merge master
  yadm stash pop
}
