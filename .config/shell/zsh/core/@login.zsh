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
# - https://github.com/b3nj5m1n/xdg-ninja
#

# Explicitly set XDG base directory defaults.
# This is done so that these variables can be assumed to be set later on.
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_LIB_HOME="$HOME/.local/lib"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

# Export needed XDG user directories.
export XDG_PROJECTS_DIR=$(xdg-user-dir PROJECTS 2>/dev/null || echo "$HOME/Projects")

# XDG paths for zsh.
export ZDATADIR=${ZDATADIR:-$XDG_STATE_HOME/zsh}
export ZCACHEDIR=${ZCACHEDIR:-$XDG_CACHE_HOME/zsh}
command mkdir -p $ZDATADIR $ZCACHEDIR

# XDG_LIB_HOME environment overrides for package managers.
export CARGO_HOME="$XDG_LIB_HOME/cargo"
export GOPATH="$XDG_LIB_HOME/go"
export NPM_CONFIG_PREFIX="$XDG_LIB_HOME/npm"
export PIPX_HOME="$XDG_LIB_HOME/pipx"
export PIPX_BIN_DIR="$PIPX_HOME/bin"

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
export HTML_TIDY="$XDG_CONFIG_HOME/tidy/tidy.conf"
export CDS_FILE="$XDG_CONFIG_HOME/cdsctl/config"
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"

# XDG_DATA_HOME environment overrides.
export TERMINFO="$XDG_DATA_HOME/terminfo"
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
# export GNUPGHOME="$XDG_DATA_HOME/gnupg" # NOTE: Does not really work for all programs
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SSB_HOME="$XDG_DATA_HOME/zoom"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export KREW_ROOT="$XDG_DATA_HOME/krew"

# XDG_STATE_HOME environment overrides.
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/repl_history"

# XDG_CACHE_HOME environment overrides.
export RANDFILE="$XDG_CACHE_HOME/openssl/randfile"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"

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
path=($XDG_BIN_HOME $XDG_BIN_HOME/my $XDG_BIN_HOME/xdg $path)

#
# Session environment
#

# Make GTK applications use the KDE file selection dialog.
export GTK_USE_PORTAL=1

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
  # Set default wine prefix.
  export WINEPREFIX='~/.local/share/wine-default'
  # Set default wine architecture.
  export WINEARCH='win32'
  # Disable prompt for wine-gecko install.
  # export WINEDLLOVERRIDES='mshtml='
  # Workaround vulkan issue with hybrid GPU setups: https://bugs.winehq.org/show_bug.cgi?id=51210
  # See also https://forum.winehq.org/viewtopic.php?f=8&t=36177
  export VK_ICD_FILENAMES='/usr/share/vulkan/icd.d/intel_icd.x86_64.json'
fi

#
# Additional PATH directories.
#

if [[ -s "$XDG_LIB_HOME/gvm/scripts/gvm" ]]; then
  # Source the default GVM environment to make go tools and programs available.
  source "/home/sgleizes/.local/lib/gvm/scripts/gvm"
fi

if (( $+commands[go] )); then
  # Add installed go binaries to PATH.
  path+=($GOPATH/bin)

  # Use the module-aware mode by default.
  export GO111MODULE='on'
fi

if (( $+commands[npm] )); then
  # Add installed node binaries to PATH.
  path+=($NPM_CONFIG_PREFIX/bin)
fi

if (( $+commands[pipx] )); then
  # Add installed python applications to PATH.
  path+=($PIPX_BIN_DIR)
fi

if [[ -f $CARGO_HOME/bin/cargo ]]; then
  # Add rust tools and installed applications to PATH.
  path+=($CARGO_HOME/bin)
fi

if [[ -f $KREW_ROOT/bin/kubectl-krew ]]; then
  # Add the kubectl plugin manager to PATH.
  path+=($KREW_ROOT/bin)
fi
