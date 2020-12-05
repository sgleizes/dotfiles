#
# Youtube-dl configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[youtube-dl] )); then
  return 1
fi

# Usability alias.
alias ydl='youtube-dl'

# Download music to my default directory for music waiting to be added to the beets library.
function youtube-dl-music {
  local artist="$1"
  local album="$2"
  local url="$3"

  ydl --extract-audio \
    --format 'bestaudio[ext=webm]/bestaudio' \
    --metadata-from-title '%(artist)s - %(title)s' \
    --output "$HOME/Audios/Pending/$artist/$album/%(title)s.%(ext)s" \
    $url ${@:4}
}

# Audio post-processing aliases.
alias ydla='youtube-dl --extract-audio --format worstaudio' # for spoken audio
alias ydlm="youtube-dl-music"                               # for music

# List formats & prompt for one.
function youtube-dl-interactive {
  local fmt
  youtube-dl --list-formats "$1" || return

  print -P "%F{blue}::%f Enter below one 'format code' listed above"
  if read -r fmt; then
    youtube-dl --format "$fmt" "$1"
  fi
}
alias ydli='youtube-dl-interactive'
