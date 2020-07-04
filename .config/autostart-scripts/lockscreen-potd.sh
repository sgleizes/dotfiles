#!/usr/bin/env sh
# Symlink the lockscreen POTD directory to the wallpaper POTD directory.
# This is required because the lockscreen disables internet access, so the POTD fails to download.
# https://www.reddit.com/r/kde/comments/711lej/picture_of_the_day_lock_screen_background_not.

PLASMA_POTD="$HOME/.cache/plasmashell/plasma_engine_potd"
SCREENLOCKER_POTD="$HOME/.cache/kscreenlocker_greet/plasma_engine_potd"

if [ -d "$PLASMA_POTD" ]; then
  mkdir -p "${SCREENLOCKER_POTD%/*}"
  ln -s "$PLASMA_POTD" "$SCREENLOCKER_POTD"
fi
