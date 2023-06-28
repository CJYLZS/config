#!/bin/zsh
ZSH="$HOME/.oh-my-zsh"

builtin_plugin_dir="$ZSH/plugins"
plugin_dir="$ZSH/custom/plugins"

custom_plugins=(
    "$plugin_dir/zsh-syntax-highlighting"
    "$plugin_dir/zsh-autosuggestions"
)
custom_plugins_url=(
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions.git"
)

if [ ! -d $ZSH ]; then
    echo 'oh-my-zsh not found, will download'
    git clone https://github.com/ohmyzsh/ohmyzsh.git --depth=1 $ZSH
fi

source $ZSH/oh-my-zsh.sh
source $builtin_plugin_dir/git/git.plugin.zsh
source $builtin_plugin_dir/vi-mode/vi-mode.plugin.zsh
source $builtin_plugin_dir/z/z.plugin.zsh
source $builtin_plugin_dir/dirhistory/dirhistory.plugin.zsh

length=${#custom_plugins[@]}

for ((i=1; i<=$length; i++)); do
    dir=${custom_plugins[$i]}
    if [ ! -d $dir ]; then
        echo "$dir not found, will download"
        git clone "${custom_plugins_url[$i]}" --depth=1 $dir &&
            source "$dir/$(basename $dir).plugin.zsh"
    else
        source "$dir/$(basename $dir).plugin.zsh"
    fi
done

# theme
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[cyan]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$fg_bold[cyan]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

function prompt_char {
	if [ $UID -eq 0 ]; then echo "%{$fg_bold[blue]%}#%{$reset_color%}"; else echo "%{$fg_bold[blue]%}$%{$reset_color%}"; fi
}

# PROMPT='%{$fg[cyan]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%}: %{$fg[green]%}%~%{$reset_color%}$(git_prompt_info) %(?, ,%{$fg[red]%}%?%{$reset_color%})
# $(prompt_char) '

PROMPT='%{$fg[green]%}%~%{$reset_color%} $(git_prompt_info) %(?, ,%{$fg[red]%}%?%{$reset_color%})
$(prompt_char) '

RPROMPT='%{$fg_bold[green]%}[%D{%H:%M:%S}]%{$reset_color%}'


alias cls='clear'
alias af='sudo find / -name '
alias hf='history 1 | fzf'
alias cx='curl -x socks5://127.0.0.1:7891 '
# alias docker='sudo docker '
# alias sys='sudo systemctl '
alias py='python3 '

bindkey '\eh'  backward-char
bindkey '\el'  forward-char
bindkey '\ek'  up-line-or-history
bindkey '\ej'  down-line-or-history 

if [ ! -f "$HOME/.zshrc" ]; then
    echo 'add .zshrc to $HOME'
    ln -s $(pwd)/zshrc $HOME/.zshrc
fi

# from https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.zsh
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# Key bindings
# ------------

# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'emulate' 'zsh' '-o' 'no_aliases'

{

[[ -o interactive ]] || return 0

# CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-}" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N            fzf-file-widget
bindkey -M emacs '^T' fzf-file-widget
bindkey -M vicmd '^T' fzf-file-widget
bindkey -M viins '^T' fzf-file-widget

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="builtin cd -- ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
zle     -N             fzf-cd-widget
bindkey -M emacs '\ec' fzf-cd-widget
bindkey -M vicmd '\ec' fzf-cd-widget
bindkey -M viins '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N            fzf-history-widget
bindkey -M emacs '^R' fzf-history-widget
bindkey -M vicmd '^R' fzf-history-widget
bindkey -M viins '^R' fzf-history-widget

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}

