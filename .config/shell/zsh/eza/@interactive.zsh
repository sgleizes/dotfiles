#
# Exa/Eza configuration module for zsh.
#

# Install exa if standalone install is requested.
# NOTE: This does not currently support eza. To upgrade when needed.
if (( $+functions[zi] )) && [[ $ZSH_STANDALONE_INSTALL ]]; then
  # Uninstall: zi delete app/exa && zi cclear && rm -f $ZI[MAN_DIR]/{man1/exa.1,man5/exa_colors.5}
  zi light-mode for id-as'app/exa' \
    from'gh-r' as'completion' nocompile lbin'!' \
    atclone'\cp -f completions/exa.zsh _exa' \
    atclone"\cp -vf man/exa.1 $ZI[MAN_DIR]/man1" \
    atclone"\cp -vf man/exa_colors.5 $ZI[MAN_DIR]/man5" \
    atpull'%atclone' \
    @ogham/exa
fi

# Abort if requirements are not met.
if (( ! $+commands[eza] )); then
  return 1
fi

# Quick switch to opt-in git support.
# To enable set `EZA_GIT` to any value.
alias eza='eza ${EZA_GIT+--git}'

# Override original aliases with similar, yet improved behavior.
alias ls='eza --group-directories-first' # list directories first by default
alias lsa='ls -a'                        # short list, hidden files
alias l='ls -l'                          # list in long format
alias ll='ls -lGh'                       # list as a grid with header
alias la='l -a'                          # list hidden files
alias lr='l -T'                          # list recursively as a tree
alias lv='l --git-ignore'                # list git-versioned files
alias lx='l --sort=ext'                  # list sorted by extension
alias lk='l --sort=size'                 # list sorted by size, largest last
alias lt='l --sort=mod'                  # list sorted by modification time, most recent last
alias ltc='l --sort=ch --time=ch'        # list sorted by change time, most recent last
alias lta='l --sort=acc --time=acc'      # list sorted by access time, most recent last

# Color theme.
if (( $terminfo[colors] >= 256 )); then
  export EZA_COLORS="\
ur=38;5;41:\
uw=38;5;41:\
ux=38;5;41;4:\
ue=38;5;41:\
gr=38;5;110:\
gw=38;5;110:\
gx=38;5;110:\
tr=38;5;9:\
tw=38;5;9:\
tx=38;5;9:\
sn=38;5;11;1:\
sb=38;5;11:\
df=38;5;173;1:\
ds=38;5;173:\
uu=38;5;41:\
gu=38;5;41:\
un=38;5;9;1:\
gn=38;5;9;1:\
da=38;5;145:\
"
elif (( $terminfo[colors] >= 8 )); then
  export EZA_COLORS="\
ur=1;32:\
uw=1;32:\
ux=1;32:\
ue=1;32:\
gr=1;34:\
gw=1;34:\
gx=1;34:\
tr=1;31:\
tw=1;31:\
tx=1;31:\
sn=33:\
sb=33:\
df=1;33:\
ds=1;33:\
uu=1;32:\
gu=1;32:\
un=1;31:\
gn=1;31:\
da=0:\
"
fi
