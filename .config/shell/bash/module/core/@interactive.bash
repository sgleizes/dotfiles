#
# Core configuration module for bash.
#

# Load the core posix module.
xsh load core -s posix

# Directory management
shopt -s autocd      # automatically change to directory if the command is a directory
shopt -s cdable_vars # allow automatic parameter expansion in cd context
shopt -s cdspell     # allow automatic spelling correction in cd context
shopt -s dirspell    # allow automatic spelling correction in pathname completion context

# History management
HISTCONTROL=ignoredups # ignore duplicate history entries
shopt -s histverify    # do not execute immediately upon history expansion

# Job management
shopt -s checkjobs # report running/suspended jobs on shell exit
shopt -s huponexit # kill jobs with SIGHUP on shell exit

# Pattern matching
shopt -s extglob # enable pattern lists separated with '|' and related operators
