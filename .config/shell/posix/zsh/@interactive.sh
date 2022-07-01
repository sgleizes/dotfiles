#
# Zsh installation module.
# This is useful to install zsh anywhere. Once xsh is installed, just run: `xsh -s posix load zsh`
# Made so simple thanks to https://github.com/romkatv/zsh-bin.
#

if command -v curl >/dev/null; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh-bin/master/install)"
elif command -v wget >/dev/null; then
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh-bin/master/install)"
else
  echo 'zsh: failed to get install script: missing curl or wget dependency'
fi
