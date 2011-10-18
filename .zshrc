# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="lambda"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want disable red dots displayed while waiting for completion
# DISABLE_COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git archlinux vi-mode zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
source /etc/profile
#export PATH=/opt/tau/x86_64/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/java/bin:/opt/java/db/bin:/opt/java/jre/bin:/usr/bin/core_perl
export EDITOR="vim"
alias ls='ls --color=auto'
alias todoc='clear && todo -c +'
alias wicd-client='wicd-client -n'
alias ta='tmux a'
alias tre='transmission-remote-cli'
alias wcd='wicd-curses'
alias ac='aria2c -c'
sm() {
    cuebreakpoints $1 | shnsplit -t "%p_-_%a_-_%n_-_%t" -o $2 $3
}
alias :D='archey -s'
