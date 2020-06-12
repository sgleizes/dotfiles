#
# Core configuration module for zsh.
#

# Do not create group/world writable files by default.
umask a=rx,u+w

#
# XDG base directory
#
# References:
# - https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# - https://wiki.archlinux.org/index.php/XDG_Base_Directory
#

# Explicitly set XDG base directory defaults.
# This is done so that these variables can be assumed to be set later on.
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_LIB_HOME="$HOME/.local/lib"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

# XDG paths for zsh.
export ZDATADIR=${ZDATADIR:-$XDG_DATA_HOME/zsh}
export ZCACHEDIR=${ZCACHEDIR:-$XDG_CACHE_HOME/zsh}
command mkdir -p $ZDATADIR $ZCACHEDIR

# Setup XDG paths for programs supporting environment overrides.
export ELINKS_CONFDIR="$XDG_CONFIG_HOME/elinks"
export GTK_RC_FILES="$XDG_CONFIG_HOME/gtk-1.0/gtkrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export KDEHOME="$XDG_CONFIG_HOME/kde4" # legacy way for KDE4 applications
export PSQLRC="$XDG_CONFIG_HOME/psql/psqlrc"
export PSQL_HISTORY="$XDG_DATA_HOME/psql/history"
export WGETRC="$XDG_CONFIG_HOME/wget/config"
export GOPATH="$XDG_DATA_HOME/go"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export RANDFILE="$XDG_CACHE_HOME/openssl/randfile"

# This must match the display manager setting.
# It should be located in XDG_RUNTIME_DIR but sddm does not allow that.
[[ -f "$XDG_CACHE_HOME/Xauthority" ]] \
  && export XAUTHORITY="$XDG_CACHE_HOME/Xauthority"

# Create parent directories for programs requiring it.
command mkdir -p \
  ${RANDFILE:h} \
  ${PSQLRC:h} \
  ${PSQL_HISTORY:h}

# XDG paths for applications supporting command line overrides are implemented
# using executable overrides in XDG_BIN_HOME. NOTE: For applications having a desktop
# launcher, it should be updated to use <command> instead of /usr/bin/<command>.

# Prepend user binaries to PATH to allow overriding system commands.
path=($XDG_BIN_HOME $XDG_BIN_HOME/xdg $path)

#
# Various session environment variables
#

# Configure gamemode to run games on the Nvidia GPU (optimus-manager).
# See https://github.com/Askannz/optimus-manager/wiki/Nvidia-GPU-offloading-for-%22hybrid%22-mode.
if (( $+commands[optimus-manager] && $+commands[gamemoderun] )) {
  export GAMEMODERUNEXEC="env \
__NV_PRIME_RENDER_OFFLOAD=1 \
__GLX_VENDOR_LIBRARY_NAME=nvidia \
__VK_LAYER_NV_optimus=NVIDIA_only"
}

# Disable prompt for wine-gecko install.
if (( $+commands[wine] )) {
  export WINEDLLOVERRIDES='mshtml=d'
}
