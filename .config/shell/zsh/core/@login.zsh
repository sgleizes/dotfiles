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

# XDG_LIB_HOME environment overrides for package managers.
export CARGO_HOME="$XDG_LIB_HOME/cargo"
export GOPATH="$XDG_LIB_HOME/go"
export NPM_CONFIG_PREFIX="$XDG_LIB_HOME/npm"

# XDG_CONFIG_HOME environment overrides.
export ANDROID_PREFS_ROOT="$XDG_CONFIG_HOME/android"
export ANDROID_EMULATOR_HOME="$XDG_DATA_HOME/android/emulator"
export ELINKS_CONFDIR="$XDG_CONFIG_HOME/elinks"
export GTK_RC_FILES="$XDG_CONFIG_HOME/gtk-1.0/gtkrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export KDEHOME="$XDG_CONFIG_HOME/kde4" # legacy way for KDE4 applications
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PSQLRC="$XDG_CONFIG_HOME/psql/psqlrc"
export WGETRC="$XDG_CONFIG_HOME/wget/config"

# XDG_DATA_HOME environment overrides.
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node/repl_history"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SSB_HOME="$XDG_DATA_HOME/zoom"

# XDG_CACHE_HOME environment overrides.
export RANDFILE="$XDG_CACHE_HOME/openssl/randfile"

# XDG path to the X server auth cookie. This must match the display manager setting.
# It should be located in XDG_RUNTIME_DIR but sddm does not allow that.
[[ -f "$XDG_CACHE_HOME/Xauthority" ]] \
  && export XAUTHORITY="$XDG_CACHE_HOME/Xauthority"

# Create parent directories for programs requiring it.
command mkdir -p \
  ${RANDFILE:h} \
  ${NODE_REPL_HISTORY:h} \
  ${PSQLRC:h} \
  ${PSQL_HISTORY:h}

# XDG paths for applications supporting command line overrides are implemented
# using executable overrides in XDG_BIN_HOME. NOTE: For applications having a desktop
# launcher, it should be updated to use <command> instead of /usr/bin/<command>.

# Prepend user binaries to PATH to allow overriding system commands.
path=($XDG_BIN_HOME $XDG_BIN_HOME/xdg $path)

#
# Session environment
#

if (( $+commands[optimus-manager] && $+commands[gamemoderun] )); then
  # Configure gamemode to run games on the Nvidia GPU (optimus-manager) and with mangohud.
  # See https://github.com/Askannz/optimus-manager/wiki/Nvidia-GPU-offloading-for-%22hybrid%22-mode.
  export GAMEMODERUNEXEC="env \
__NV_PRIME_RENDER_OFFLOAD=1 \
__GLX_VENDOR_LIBRARY_NAME=nvidia \
__VK_LAYER_NV_optimus=NVIDIA_only \
MANGOHUD_DLSYM=1 \
mangohud"
fi

if (( $+commands[wine] )); then
  # Disable prompt for wine-gecko install.
  export WINEDLLOVERRIDES='mshtml='
fi

if (( $+commands[go] )); then
  # Add installed go binaries to PATH.
  path+=($GOPATH/bin)

  # Use the module-aware mode by default.
  export GO111MODULE='on'
fi

if (( $+commands[npm] )); then
  # Add installed node binaries to PATH.
  path+=($XDG_LIB_HOME/npm/bin)
fi
