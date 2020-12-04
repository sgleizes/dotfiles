#
# Todo.txt configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[todo.sh] )); then
  return 1
fi

# See also:
# https://github.com/todotxt/todo.txt-cli/blob/master/USAGE.md
# https://github.com/todotxt/todo.txt-cli/wiki/Todo.sh-Add-on-Directory
# Possibly interesting addons:
# - https://github.com/rlpowell/todo-text-stuff/blob/master/ice_recur
# - https://github.com/rlpowell/todo-text-stuff/blob/master/templated_checklists

# Path to the todo.txt-cli configuration file.
export TODOTXT_CFG_FILE="$XDG_CONFIG_HOME/todotxt/config"

# Usability aliases
alias todo='todo.sh'
alias t='todo'
