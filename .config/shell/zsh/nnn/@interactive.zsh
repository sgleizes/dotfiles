#
# n³ configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Abort if requirements are not met.
if (( ! $+commands[nnn] )) {
  return 1
}

# nnn configuration: https://github.com/jarun/nnn/wiki/Usage#configuration.
export NNN_ARCHIVE="\\.(7z|a|ace|alz|arc|arj|bz|bz2|cab|cpio|deb|gz|jar|lha|lz|lzh|lzma|lzo|rar|rpm|rz|t7z|tar|tbz|tbz2|tgz|tlz|txz|tZ|tzo|war|xpi|xz|Z|zip)$"
export NNN_BMS_DIR="$ZMARKDIR" # for bookmark plugin
export NNN_COLORS='#040a0b05;4235'
export NNN_FCOLORS='447127d6005d5cf9c67ec5c4'
export NNN_OPTS="aErxF"
export NNN_SSHFS='sshfs -o reconnect,idmap=user'
# export NNN_TRASH=1 # NOTE: Dangerous: no confirmation + triggers on failed ^X...

# Plugins configuration.
export NNN_PLUG="\
b:bookmarks;\
c:fzf-fcd;\
C:fzf-cd;\
d:-diffs;\
e:suedit;\
f:fzf-fopen;\
F:fzf-open;\
g:gpge;\
G:gpgd;\
i:beets-import;\
k:-kdeconnect;\
l:-_git log -p*;\
n:bulknew;\
N:-opendir;\
o:finder;\
p:-_less \$nnn*;\
P:-preview-tui;\
u:getplugs;\
x:-hexview;\
"

# Configure cd on quit.
function nnn {
  # Block nesting of nnn in subshells
  if [[ $NNNLVL ]] && (( ${NNNLVL:-0} >= 1 )); then
    echo "nnn is already running"
    return
  fi

  # Generate bookmarks keys based on existing symlinks.
  unset NNN_BMS
  for link in $NNN_BMS_DIR/*(N@); {
    local markname="${link:t}"
    local markpath="${link:A}"
    export NNN_BMS="$NNN_BMS$markname[1]:$markpath;"
  }

  # The default behavior is to cd on quit (nnn checks if NNN_TMPFILE is set)
  # To cd on quit only on ^G, remove the "export" as in:
  #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
  # NOTE: NNN_TMPFILE is fixed, should not be modified
  export NNN_TMPFILE="$XDG_CONFIG_HOME/nnn/.lastd"

  # Run nnn with modified environment:
  # - LC_COLLATE: Show hidden files on top.
  LC_COLLATE="C" command nnn "$@"

  if [[ -f $NNN_TMPFILE ]]; then
    source $NNN_TMPFILE
    command rm -f $NNN_TMPFILE >/dev/null
  fi
}

# Usability aliases.
alias n='nnn'
alias N='sudo -E nnn -dH'
alias nsel="cat ${NNN_SEL:-$XDG_CONFIG_HOME/nnn/.selection} | tr '\0' '\n'"

# Shortcut to open nnn.
function open-nnn {
  exec </dev/tty
  nnn
  zle send-break # redisplay or reset-prompt don't properly refresh the prompt
}
zle -N open-nnn
bindkey "$keys[Control]O$keys[Control]N" open-nnn
