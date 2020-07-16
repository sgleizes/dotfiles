#
# Core configuration module for zsh.
#

# Load the core posix module.
xsh load core -s posix

# Reload the shell configuration without instant prompt to show output in real time.
alias reload='POWERLEVEL9K_INSTANT_PROMPT=off exec zsh'

#
# General
#

setopt no_clobber           # do not allow '>' to truncate existing files, use '>!'
setopt append_create        # allow '>>' to create files
setopt correct              # try to correct command spelling
setopt interactive_comments # allow comments in interactive shells
setopt rc_quotes            # allow 'henry''s garage' instead of 'henry'\''s garage'

#
# Pattern matching
#

setopt glob_dots     # include dotfiles in globbing
setopt extended_glob # enable '#', '~', '^' operators and flags in patterns
setopt brace_ccl     # allow brace character class list expansion

# Disable globbing for specific commands.
alias fc='noglob fc'
alias fd='noglob fd'
alias find='noglob find'
alias ftp='noglob ftp'
alias history='noglob history'
alias locate='noglob locate'
alias rsync='noglob rsync'
alias scp='noglob scp'
alias sftp='noglob sftp'

#
# Job management
#

setopt auto_continue  # auto-resume jobs when using disown
setopt auto_resume    # allow foregrounding jobs using command names
setopt long_list_jobs # print job notifications with the process ID

#setopt no_check_jobs # do not report running/suspended jobs on shell exit
#setopt no_hup        # do not kill jobs with SIGHUP on shell exit

alias j='jobs -l'

#
# Reports
#

# Report timing statistics for any command that took more than 15s CPU time to execute.
REPORTTIME=15

# Extended output for the time builtin.
TIMEFMT=':: time report for `%J`
:: %U user :: %S system :: %*E total
:: %P cpu :: %KKB mem-avg :: %MKB mem-max'

# Report all login/logout events.
WATCH='all'
WATCHFMT=':: %n has %a %l from %(M:%M:localhost) at %T'

#
# Modules (explicitly wanted)
#

[[ $COLORTERM == *(24bit|truecolor)* ]] \
  || zmodload zsh/nearcolor # match 24-bit colors if unsupported
zmodload zsh/parameter      # provide access to internal hash tables
zmodload zsh/terminfo       # interface to the terminfo database
zmodload zsh/zutil          # add some essential builtins, e.g. zstyle

#
# Functions
#

# Load 8-bit color arrays if supported.
(( $terminfo[colors] >= 8 )) && autoload -Uz colors && colors

# Variant of xargs more suited to accept long argument lists.
# https://github.com/zsh-users/zsh/blob/master/Functions/Misc/zargs
autoload -Uz zargs

# Multiple move/copy based on pattern matching.
# https://github.com/zsh-users/zsh/blob/master/Functions/Misc/zmv
autoload -Uz zmv
alias zmv='noglob zmv -vW'
alias zcp='zmv -C'
alias zln='zmv -L'

# Zsh calculator in place of bc.
# https://github.com/zsh-users/zsh/blob/master/Functions/Misc/zcalc
autoload -Uz zcalc
alias zcalc='ZDOTDIR=$ZDATADIR zcalc' # use the XDG data dir for history
alias calc='ZDOTDIR=$ZDATADIR noglob zcalc -e'
aliases[=]='calc'

# Print columns 1 2 3 ... n.
function slit { awk "{ print ${(j:,:):-\$${^@}} }"; }

# Autoload all appropriate functions from a directory.
# This was totally stolen from prezto.
# Usage: autoload_dir <dir>
function autoload_dir {
  local dir="$1"
  local skip_glob='^([_.]*|prompt_*_setup|*~)(-.N:t)'
  local func

  # Extended globbing is needed for listing autoloadable function directories.
  setopt local_options extended_glob

  fpath=($dir(-/FN) $fpath)
  for func in $dir/$~skip_glob; {
    autoload -Uz "$func"
  }
}

# Autoload all module functions.
autoload_dir ${0:h}/function

#
# VPN
#

if (( $+commands[nordvpn] )) {
  alias vpn='nordvpn'
  alias v='vpn'
}

#
# Speech synthesizer
#

# Usability aliases for espeak-ng.
if (( $+commands[espeak-ng] )) {
  alias speak-en='speak-ng -v gmw/en-US'
  alias speak-fr='speak-ng -v roa/fr'
}

#
# Golang
#

if (( $+commands[go] )) {
  # Add installed go binaries to PATH.
  path+=($GOPATH/bin)

  # Use the module-aware mode by default.
  export GO111MODULE='on'
}


#
# Node
#

if (( $+commands[npm] )) {
  # Add installed node binaries to PATH.
  path+=($XDG_LIB_HOME/npm/bin)
}

#
# External core plugins
#

# Abort if requirements are not met.
if [[ $TERM == 'dumb' || $+functions[zinit] == 0 ]] {
  return 2
}

# Setup LS_COLORS.
# Completion styles are configured with these colors in the completion module.
# See https://zdharma.org/zinit/wiki/LS_COLORS-explanation/
zinit ice wait'0b' lucid depth=1 reset \
  atclone'sed -i "/DIR/c\DIR 38;5;39;1" LS_COLORS
          sed -i "/EXEC/c\EXEC 38;5;214;1" LS_COLORS
          dircolors -b LS_COLORS > .dircolors.sh' \
  atpull'%atclone' nocompile'!' \
  pick'.dircolors.sh' \
  atload'zstyle ":completion:*:default" list-colors ${(s.:.)LS_COLORS}'
zinit light trapd00r/LS_COLORS
