fish_vi_key_bindings

set -l vi_mode_icon 'λ'
set -g tide_vi_mode_default_icon $vi_mode_icon
set -g tide_vi_mode_default_color blue
set -g tide_vi_mode_insert_icon $vi_mode_icon
set -g tide_vi_mode_replace_icon $vi_mode_icon
set -g tide_vi_mode_replace_color green
set -g tide_vi_mode_visual_icon $vi_mode_icon
set -g tide_vi_mode_visual_color yellow
set -g tide_left_prompt_items 'vi_mode' 'pwd' 'git'
set -g tide_right_prompt_items 'cmd_duration' 'status'
set -g tide_cmd_duration_threshold 500
set -g tide_cmd_duration_decimals 1

alias f='ranger'
alias .f='git --git-dir="$HOME/|dotfiles|/" --work-tree=$HOME'
