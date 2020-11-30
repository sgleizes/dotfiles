#
# Prezto module for zsh.
# 
# Adaptation of the original prezto runcom at:
# https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zshenv
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) ]]; then
  xsh load prezto login
fi
