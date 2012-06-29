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
export PATH=$HOME/.gem/ruby/1.9.1/bin:$PATH
export GEM_HOME=$HOME/.gem/ruby/1.9.1
export EDITOR="vim"
alias gcam='gc -am'
alias gf='g fetch'
alias gd='g diff'
alias tdc='clear && todo -c +'
alias tdd='todo -d '
tda() {
    todo -g $1 -a
}
alias tn='tmux'
alias ta='tmux a'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'
alias tre='transmission-remote-cli'
alias wcd='wicd-curses'
alias ac='aria2c -c'
alias rs='canto'
alias f='ranger'
alias y='yaourt'
sm() {
    cuebreakpoints *cue | shnsplit -t "%p_-_%a_-_%n_-_%t" -o flac *$1
}
alias :D='archey -s'
alias mt="udevil mount"
alias umt="udevil umount"
alias umta="devmon -u"
plo() {
    pdflatex $1.tex && zathura $1.pdf
}
alias p2="python2"
alias p3="python3"
alias ip2="ipython2"
alias ip3="ipython"
alias nt="nosetests3"
alias upk='atool -x'
alias upt='atool -X'
alias pk='atool -a'
prepend() {
    for i in *; do mv $i $1$i; done
}
