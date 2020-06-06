#
# Fortune module for zsh.
#

# Abort if requirements are not met.
if (( ! $+commands[fortune] )) {
  return 1
}

# Fortune cookie selection settings.
FORTUNE_LENGTH=420
FORTUNE_COOKIES=(
  cookie
  computers
  definitions
  drugs
  fortunes
  humorists
  linux
  love
  paradoxum
  people
  platitudes
  tao
  wisdom
)

# The fortune mode can be one of the following:
# - none:  do not show fortunes.
# - basic: show fortunes text only.
# - pony:  show fortunes using ponysay.
: ${FORTUNE_LOGIN:=none}
: ${FORTUNE_INTERACTIVE:=none}

# Print a randomly selected cookie.
function zfortune {
  fortune -n $FORTUNE_LENGTH -s $FORTUNE_COOKIES[@]
}

# Print a randomly selected cookie using ponysay, if available.
function zfortune-pony {
  (( $+commands[ponysay] && $terminfo[colors] >= 256 )) \
    && zfortune | ponysay -b unicode +c '38;5;75' -W 85 -F \
    || zfortune
}

# Select the fortune to show according to the selected modes.
fortune_mode="$FORTUNE_INTERACTIVE"
[[ -o login ]] && fortune_mode="$FORTUNE_LOGIN"
case $fortune_mode {
  basic) zfortune ;;
  pony) zfortune-pony ;;
}

unset fortune_mode
