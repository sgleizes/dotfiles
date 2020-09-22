#
# Core configuration module.
#

# Fetch the current TTY.
[ ! "$TTY" ] && TTY="$(tty)"

# Disable control flow (^S/^Q).
[ -r "${TTY:-}" ] && [ -w "${TTY:-}" ] && command -v stty >/dev/null \
  && stty -ixon <"$TTY" >"$TTY" || true

# General parameters and options.
HISTFILE=        # in-memory history only
set -o noclobber # do not allow '>' to truncate existing files, use '>|'
set -o notify    # report the status of background jobs immediately

# Elementary.
alias reload='exec "$XSHELL"' # reload the current shell configuration
alias sudo='sudo '            # preserve aliases when running sudo
alias su='su -l'              # safer, simulate a real login

# Human readable output.
alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias df='df -h' du='du -h'

# Verbose and safe file operations.
alias cp='cp -vi' mv='mv -vi' ln='ln -vi' rm='rm -vI'
# Use the patched progress bar version if available.
if command -v advcp >/dev/null; then
  alias cp='advcp -gvi' mv='advmv -gvi'
fi

# Directory listing.
alias dud='du -d1' # show total disk usage for direct subdirectories only
alias ls='ls --color=auto --group-directories-first' # list directories first by default
alias lsa='ls -A'                                    # short list, hidden files
alias l='ls -gGh' # list human readable sizes, no group/owner
alias ll='ls -lh' # list human readable sizes
alias la='ll -A'  # list human readable sizes, hidden files
alias lr='ll -R'  # list human readable sizes, recursively
alias lx='ll -XB' # list sorted by extension (GNU only)
alias lk='ll -Sr' # list sorted by size, largest last
alias lt='ll -tr' # list sorted by modification time, most recent last
alias ltc='lt -c' # list sorted by change time, most recent last
alias lta='lt -u' # list sorted by access time, most recent last
command -v sl >/dev/null && alias sl='sl -al' # mystyping cure

# Tree directory listing.
alias tl='tree --dirsfirst --filelimit=50'
alias tla='tl -a -I .git'

# Making/Changing directories.
alias mkdir='mkdir -pv'
alias mkd='mkdir'
alias rmd='rmdir'
mkcd() { mkd "$@" && cd "${@:$#}"; } # ${@:$#} is a bashism

# Systemd convenience.
alias sc='systemctl'
alias scu='sc --user'
alias jc='journalctl --catalog'
alias jcb='jc --boot=0'
alias jcf='jc --follow'
alias jce='jc -b0 -p err..alert'

# Simple progress bar output for downloaders by default.
alias curl='curl --progress-bar'
alias wget='wget -q --show-progress'

# Simple and silent desktop opener.
alias open='nohup xdg-open >|$(mktemp --tmpdir nohup.XXXX)'
alias o='open'

# Preferred applications.
alias e='${VISUAL:-$EDITOR}'
alias p='$PAGER'
alias b='$BROWSER'

# Serve a directory via HTTP.
alias http-serve='python3 -m http.server'

# Make etckeeper simpler to use.
if command -v etckeeper >/dev/null; then
  alias etck='sudo etckeeper'
  alias etcg='etck vcs'
  alias etclog='etck vcs log --oneline'
fi
