#
# Completion configuration module for zsh.
#

# Explicitly load complist so that widgets are re-defined by compinit.
# See zshcompsys(1) and zshmodules(1).
zmodload zsh/complist

# Define the completers to use.
# The correct, approximate and substring completers are only used when
# completion is attempted a second time on the same string.
_primary_completers=(_expand _complete _prefix)
_secondary_completers=(_correct _approximate _complete:substring)
zstyle -e ':completion:*' completer '
  reply=($_primary_completers[@])
  if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] {
    _last_try="$HISTNO$BUFFER$CURSOR"
  } else {
    reply+=($_secondary_completers[@])
  }
'

# Define the matchers to use: regular, partial-word, then substring completion.
# Additional standard matchers not included:
# - 'm:{[:lower:]}={[:upper:]}': case-insensitive (lowercase matches uppercase)
# - 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}': case-insensitive (all)
zstyle ':completion:*' matcher-list '' 'r:|[._-]=* r:|=*'
zstyle ':completion:*:substring:*' matcher-list 'l:|=* r:|=*'

#
# Completer settings
#

LISTMAX=5000            # almost disable asking for long completion lists.
setopt complete_in_word # complete from both ends of the current word

# General completion settings.
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose true
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' add-space true
zstyle ':completion:*' insert-unambiguous false
zstyle ':completion:*' original false
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' squeeze-slashes true

# Enable caching for any completions using it.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$ZCACHEDIR/zcompcache"

# Error settings for _correct and _approximate completers.
# Increase the number of errors based on the length of the typed word.
# But make sure to cap (at 7) the max-errors to avoid hanging.
zstyle ':completion:*:correct:*' max-errors 1 not-numeric
zstyle -e ':completion:*:approximate:*' max-errors '
  _len=$(( ($#PREFIX+$#SUFFIX)/3 ))
  reply=($(( $_len > 7 ? 7 : $_len )) not-numeric)
'

#
# Group settings
#

# Group matches and describe.
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:*expansions' format ' %F{cyan}-- %d --%f'
zstyle ':completion:*:messages' format '%F{blue} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' select-prompt '%S%l lines (%p)%s'

# Group ordering overrides.
zstyle ':completion:*:expand:*' group-order all-expansions expansions
zstyle ':completion:*:*:-subscript-:*' group-order indexes parameters
zstyle ':completion:*:*:cd:*' group-order \
  local-directories directory-stack path-directories

#
# Color settings
#

# Default colors for file completion listings.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Colors for command completion (derived from LS_COLORS).
zstyle ':completion:*:-command-:*:commands' list-colors '=*=38;5;214;1'
zstyle ':completion:*:builtins' list-colors '=*=38;5;214'
zstyle ':completion:*:aliases' list-colors '=*=38;5;214;3'

# Colors for listing of subcommands, options, ...
zstyle ':completion:*:*commands' list-colors \
  '=(#b)*(-- *)=38;5;214;1=0' '=*=38;5;214;1'
zstyle ':completion:*:options' list-colors \
  '=(#b)*(-- *)=38;5;6;1=0' '=*=38;5;6;1'
zstyle ':completion:*:directory-stack' list-colors \
  '=(#b)* -- (*)=0=38;5;39;1'

#
# Command/Tag specific settings
#

# Do not complete internal functions and parameters.
zstyle ':completion:*:functions' ignored-patterns \
  '([-_.:+→@/]*|pre(cmd|exec))' \
  '(instant_prompt_|prompt_|(powerlevel|p)(9|10)k)*~p10k'
zstyle ':completion:*:parameters' ignored-patterns \
  '(_*|*(P9K|POWERLEVEL9K)*)'

# Directory completion settings.
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# History completion settings.
zstyle ':completion:*' range $LISTMAX           # search the last LISTMAX words
zstyle ':completion:*' remove-all-dups true     # remove all duplicate matches
zstyle ':completion:*:history-words' list true  # always list matches
zstyle ':completion:*:history-words' stop false # do not stop at beginning/end

# User completion settings.
# These will vary on different systems and should be customized.
zstyle ':completion:*:users' ignored-patterns \
  avahi bin colord daemon dbus ftp geoclue git http mail \
  nobody nvidia-persistenced polkitd postgres rtkit sddm \
  usbmux uuidd 'systemd-*' '_*'

# Ignore multiple entries for specific commands.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other

# Process management completion settings.
zstyle ':completion:*:processes' command 'ps -u $USER -o pid,command'
zstyle ':completion:*:processes' list-colors \
  '=(#b) #([0-9]#) #(*)=0=38;5;9;1=38;5;180'
zstyle ':completion:*:processes-names' command 'ps -u $USER -o command'
zstyle ':completion:*:(kill|wait):*' insert-ids menu   # convert process name to a menu of possible IDs
zstyle ':completion:*:(kill|wait):*' force-list always # show the list even for a direct match

# Man completion settings.
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Hostname completion settings, totally readable.
_etc_host_ignores=("::1" "127.0.1.1" "$HOST*")
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%(\#${_etc_host_ignores:+|${(j:|:)~_etc_host_ignores}})*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Remote operations completion settings.
zstyle ':completion:*:(ssh|scp|rsync|mosh):*' sort false
zstyle ':completion:*:(ssh|scp|rsync|mosh):*' tag-order \
  'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order \
  users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:(ssh|mosh):*' group-order \
  users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns \
  '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns \
  '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns \
  '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' \
  '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Add alternative location of completions installed with package manager.
fpath+=('/usr/share/zsh/vendor-completions/')

#
# Additional completion definitions
#

# Abort if requirements are not met, run compinit synchronously in this case.
if (( ! $+functions[zinit] )) {
  autoload -Uz compinit && compinit -d "$ZCACHEDIR/zcompdump"
  return 0
}

# Additional completion definitions.
# This will run compinit when the plugin is loaded and replay all previous
# calls to compdef. All external completions should be loaded before.
# See https://github.com/zdharma/zinit#calling-compinit-with-turbo-mode
zinit ice wait lucid depth=1 blockf \
  atpull'zinit creinstall -q .' \
  atload'zicompinit; zicdreplay'
zinit light zsh-users/zsh-completions
