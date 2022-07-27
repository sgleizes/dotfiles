#
# This file is sourced automatically by xsh if the current shell is `zsh`.
# 
# It should merely register the modules to be loaded for each runcom:
# env, login, interactive and logout.
# The order in which the modules are registered defines the order in which
# they will be loaded. Try `xsh help` for more information.
#

# Profiling of shell functions. To run zprof, execute:
#   ZSH_PROF='' zsh -ic zprof
(( $+ZSH_PROF )) && zmodload zsh/zprof

# Setup the terminal first.
xsh module term interactive

# Install and load the zi plugin manager.
xsh module zi interactive
# Load the homebrew module so that programs can be found in path.
xsh module brew interactive:login

# Load the tmux module early in case autostart is enabled.
xsh module tmux interactive:login
# Load the prompt module next to enable powerlevel10k instant prompt.
xsh module prompt interactive

# Load the core modules to set shell options early and provide core aliases.
xsh module core      interactive:env:login
xsh module directory interactive
xsh module history   interactive

# Load application-specific modules that have no specific requirements.
xsh module archive    interactive
xsh module direnv     interactive
xsh module docker     interactive
xsh module exa        interactive
xsh module ssh        interactive
xsh module gpg        interactive:login
xsh module pager      interactive:env
xsh module rclone     interactive
xsh module restic     interactive
xsh module ripgrep    interactive
xsh module trash      interactive:logout
xsh module unison     interactive:login
xsh module yadm       interactive # load before git
xsh module youtube-dl interactive

# Load the completion system and define core ZLE widgets and bindings.
xsh module completion interactive
xsh module zle        interactive # load after completion

# Load additional application-specific modules that provide and bind ZLE widgets.
xsh module browser        interactive:env
xsh module editor         interactive:env
xsh module kmon           interactive
xsh module fzf            interactive
xsh module fasd           interactive
xsh module git            interactive
xsh module jq             interactive
xsh module nnn            interactive
xsh module pacman         interactive
xsh module you-should-use interactive # load after git

# Load the modules that wrap ZLE widgets after they have all been defined.
xsh module syntax-highlighting      interactive
xsh module history-substring-search interactive
xsh module autosuggestion           interactive

# Finally, load welcoming and safeguard modules.
xsh module fortune interactive:logout
xsh module zopt    interactive
xsh module zkey    interactive
