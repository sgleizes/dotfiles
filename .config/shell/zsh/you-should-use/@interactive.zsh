#
# You-should-use configuration module for zsh.
#
# NOTE: This module needs all git wrappers to be defined and should be loaded
# after the git module.
#

# Abort if requirements are not met.
if (( ! $+functions[zi] )); then
  return 1
fi

# Configure you-should-use.
export YSU_MESSAGE_POSITION="after"
export YSU_MESSAGE_FORMAT="$fg_bold[yellow]\
Found existing %alias_type for '$fg[green]%command$fg[yellow]'. \
You should use: '$fg[green]%alias$fg[yellow]'$reset_color"

# Patch the plugin to work with all defined git wrappers and aliases.
# Also remove global aliases support.
function _patch_zsh_you_should_use {
  sed -i "/preexec _check_global_aliases/d" you-should-use.plugin.zsh
  (( $+functions[_list_git_wrappers] )) \
    && sed -i "s/= \"git /= ("${(j:|:)$(_list_git_wrappers)}")\" /g" you-should-use.plugin.zsh
  unfunction _patch_zsh_you_should_use
}

# Setup you-should-use, without global aliases support.
# The plugin is also patched to work with all defined git wrappers and aliases.
zi ice wait'0b' lucid depth=1 reset \
  atclone'_patch_zsh_you_should_use' \
  atpull'%atclone' nocompile'!'
zi light MichaelAquilina/zsh-you-should-use
