#
# Fortune module for zsh.
#

# Abort if requirements are not met.
if [[ $+commands[fortune] == 0 || ! -o interactive ]] {
  return 1
}

GOODBYES=(
  "So long and thanks for all the fish."
  "Stay out of trouble."
  "I’m out of here."
  "Peace out!"
  "Long live and prosper!"
  "It has been emotional, bye."
  "It was nice to see you again."
  "See you on the other side."
  "Oh, and in case I don't see you — good afternoon, good evening, and good night!"
  "Don't forget to come back!"
  "Be good and don't get caught."
  "May the force be with you... always."
  "Next time, bring more cookies."
  "Party easy, drive safe, and return with a smile on your face."
  "Until next time."
  "Come back when you can't stay so long."
)

# Print a randomly-chosen message.
print $GOODBYES[$(( $RANDOM % ${#GOODBYES} + 1 ))]
