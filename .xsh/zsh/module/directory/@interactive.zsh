#
# Directory configuration module for zsh.
#

setopt auto_cd           # automatically change to directory if the command is a directory
setopt auto_pushd        # make cd push the old directory onto the directory stack
setopt pushd_ignore_dups # do not push duplicates onto the directory stack
setopt pushd_minus       # reverse the meaning of '+' and '-' for the directory stack
setopt cdable_vars       # allow automatic parameter and '~' expansion in cd context
setopt cd_silent         # never print the working directory after cd

# Directory stack helpers.
alias ds='dirs -v'
for index ({1..9}) alias "$index"="cd -$index"; unset index

#
# Named directories
#

: ${ZMARKDIR:=$ZDATADIR/zmark}

# Populate the named directory hash table.
for link in $ZMARKDIR/*(N@); {
  hash -d -- ${link:t}=${link:A}
}

# Manage directory marks.
function zmark {
  [[ -d $ZMARKDIR ]] || command mkdir -p $ZMARKDIR

  # When no arguments are provided, just display existing marks.
  if (( $# == 0 )) {
    for link in $ZMARKDIR/*(N@); {
      local markname="$fg_bold[yellow]${link:t}$reset_color"
      local markpath="$fg_bold[blue]${link:A}$reset_color"
      printf '%s -> %s\n' $markname $markpath
    } | column -t
    return 0
  }

  # Otherwise, we may want to add a mark or delete an existing one.
  local -a delete
  zparseopts -D d=delete
  if (( $+delete[1] )) {
    # With `-d`, we delete an existing mark
    [[ $1 ]] && command rm -v $ZMARKDIR/$1
  } else {
    # Otherwise, add a mark to the current directory.
    # The first argument is the bookmark name. `.` is special and means the
    # mark should be named after the current directory.
    local name=$1
    [[ ! $name || $name == '.' ]] && name=${PWD:t}
    command ln -vs $PWD $ZMARKDIR/$name
    hash -d -- ${name}=${PWD}
  }
}
alias mark='zmark'
