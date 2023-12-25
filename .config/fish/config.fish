fish_vi_key_bindings

set -g fish_greeting

eval (/opt/homebrew/bin/brew shellenv)

set -x GOPATH "$HOME/.go/"
fish_add_path -g "$HOME/.bin/" "$HOME/.local/bin/" "$GOPATH/bin/" "$HOME/.cargo/bin" "$HOME/.docker/bin"

complete -c op -e

alias .f='git --git-dir="$HOME/.files/" --work-tree=$HOME'

alias f='ranger'

alias t='tmux'
alias tn='t'

alias g='git'
alias gst='g st'
alias gd='g d'

alias v-c='video-compare -m vstack -d -w x1600'
