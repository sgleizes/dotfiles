#
# Pacman configuration module for zsh.
#
# NOTE: This module defines additional ZLE widgets and bindings and
# therefore should be loaded after the zle module.
#

# Abort if requirements are not met.
if (( ! $+commands[pacman] || ! $+commands[expac] )) {
  return 1
}

#
# Basic pacman aliases
#

alias pac='pacman'                  # short for pacman
alias pacs='pac -S'                 # install packages
alias pacu='pac -Sy'                # synchronize package databases
alias pacU='pac -Syu'               # upgrade installed packages
alias pacrm='pac -Rns'              # remove packages
alias pacrmo='pacrm $(pac -Qqdt)' # remove orphan packages

#
# Advanced pacman utilities
#

# List explicitly installed native packages not in `base` nor `base-devel`
# with size and description.
# Usage: paclist [<filters...>]
function paclist {
  expac -H M '%011m\t%-20n\t%10d' \
    $(comm -23 \
      <(pacman -Qqe $@ | sort) \
      <({ pacman -Qqg base-devel; expac -l '\n' '%E' base; } | sort | uniq)) \
    | sort -n
}

# List package variants with additional filters.
function paclist-native { paclist -n $@; }
function paclist-foreign { paclist -m $@; }
function paclist-unrequired { paclist -t $@; }

# List orphan packages with size and description.
function paclist-orphan {
  expac -H M '%011m\t%-20n\t%10d' "${=$(pacman -Qqdt)}" | sort -n
}

# List the packages marked for upgrade with their download size.
function paclist-outdated {
  expac -S -H M '%k\t%n' "${=$(pacman -Qqu)}" | sort -n
}

# List files owned by a package with size.
# Usage: pacfiles <package>
function pacfiles {
  pacman -Qlq "$1" | grep -v '/$' | xargs -r du -h | sort -h
}

# Open the web page corresponding to the given package.
# Usage: pacweb <package>
function pacweb {
  pkg="$1"
  info="$(pacman -Si "$pkg")"
  if [[ ! $info ]] {
    return
  }
  repo="$(grep '^Repo' <<<$info | grep -oP '[^ ]+$')"
  arch="$(grep '^Arch' <<<$info | grep -oP '[^ ]+$')"
  ${(z)BROWSER} "https://archlinux.org/packages/$repo/$arch/$pkg/"
}

alias pacl='paclist'
alias pacln='paclist-native'
alias paclf='paclist-foreign'
alias paclu='paclist-unrequired'
alias pacf='pacfiles'
alias pacw='pacweb'

# Additional functions using `fd`.
if (( $+commands[fd] )) {
  # List pacnew and pacsave files.
  function pacnew {
    fd -HI ".+\.pac(new|save)" /etc
  }

  alias pacn='pacnew'
}

# Additional functions using the fuzzy finder.
if (( $+commands[fzf] )) {
  # Browse installed packages with a preview of package information and files.
  function pacview {
    pacman -Qq | FZF_HEIGHT="${FZF_HEIGHT:-80%}" fzf \
      --preview 'pacman -Qiil {}' \
      --bind 'enter:execute(pacman -Qil {} | less -+F)' \
      --query "$*"
  }

  # Browse for packages to install with a preview of package information.
  function pacbrowse {
    pacman -Sl | FZF_HEIGHT="${FZF_HEIGHT:-80%}" fzf \
      --multi \
      --with-nth '2..' --nth '1' \
      --preview 'pacman -Sii {2}' \
      --query "$*" \
      | awk '{print $2}' | xargs -ro sudo pacman -S
  }


  # ZLE widgets.
  function open-pacbrowse {
    print
    pacbrowse
    zle redisplay
  }
  zle -N pacview
  zle -N open-pacbrowse
  bindkey "$keys[Control]O$keys[Control]V" pacview
  bindkey "$keys[Control]O$keys[Control]I" open-pacbrowse

  alias pacv='pacview'
  alias pacb='pacbrowse'
}

#
# AUR utilities
#

# Open the web page corresponding to the given AUR package.
# Usage: aurweb [<package>]
function aurweb {
  ${(z)BROWSER} "https://aur.archlinux.org/packages/$1"
}

# Clone a package from the AUR and change to the cloned directory.
# Usage: aurget <package>
function aurget {
  [[ $1 ]] && git clone "https://aur.archlinux.org/$1" $1 && cd $1
}

# Sync dependencies, install package, remove dependencies and cleanup.
alias aurmake='makepkg -sirc'
