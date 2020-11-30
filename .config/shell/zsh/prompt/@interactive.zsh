#
# Prompt configuration module for zsh.
#

# Basic prompt theme.
theme='redhat'

# Use powerlevel10k if available.
if (( $+functions[zinit] )) {
  # Enable Powerlevel10k instant prompt. Should run early during interactive shell setup.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must run before this block; everything else may run after.
  if [[ $+ZSH_PROF == 0 && -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]] {
    source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
  }

  zinit ice depth=1 pick'/dev/null'
  zinit light romkatv/powerlevel10k
  zinit fpath --front romkatv/powerlevel10k

  theme='powerlevel10k'
}

# Disable prompt theme in dumb terminals.
if [[ $TERM == 'dumb' ]] {
  theme='off'
}

# Load and execute the prompt theming system.
autoload -Uz promptinit && promptinit
# Load the selected theme.
prompt $theme

# Load the p10k configuration according to the capabilities of the terminal.
# To create a new configuration, run `p10k configure`.
if [[ $theme == 'powerlevel10k' ]] {
  (( $terminfo[colors] >= 256 )) \
    && source $XDG_CONFIG_HOME/powerlevel10k/p10k.zsh \
    || source $XDG_CONFIG_HOME/powerlevel10k/p10k-portable.zsh

  # Additional customizations.
  POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~|/run/media/*'

  fpath[1]=() # prompt functions are loaded - cleanup fpath
}

unset theme
