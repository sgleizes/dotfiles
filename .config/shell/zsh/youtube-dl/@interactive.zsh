#
# Youtube-dl configuration module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[youtube-dl] )); then
  return 1
fi

# Usability alias.
alias ydl='youtube-dl'

# Autoload all module functions.
autoload_dir ${0:h}/function

# Audio post-processing aliases.
alias ydla='youtube-dl-audio --extract-audio --format worstaudio' # for spoken audio
alias ydlm='youtube-dl-audio'                                     # for music
alias ydls='youtube-dl-split'                                     # split into tracks

# List formats & prompt for one.
alias ydli='youtube-dl-interactive'
