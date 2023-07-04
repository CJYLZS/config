#!/bin/zsh

tmux_conf=$HOME/.tmux.conf
plugin_dir=$HOME/.tmux/plugins
# tpm_dir=$HOME/.tmux/plugins/tpm
# tpm_url="https://github.com/tmux-plugins/tpm"


if [ ! -d $plugin_dir ]; then
    mkdir -p $plugin_dir
fi

# if [ ! -d $tpm_dir]; then
#     echo 'tpm not found, will download'
#     git clone $tpm_url --depth=1 $tpm_dir
# fi
plugins=(
    "$plugin_dir/tmux-fzf"
)
urls=(
    "https://github.com/sainnhe/tmux-fzf.git"
)

length=${#plugins[@]}
for ((i=1; i<=$length; i++)); do
    dir=${plugins[$i]}
    if [ ! -d $dir ]; then
        echo "$dir not found, will download"
        git clone "${urls[$i]}" --depth=1 $dir
    fi
done


if [ ! -f $tmux_conf ]; then
    ln -s $(pwd)/tmux.conf $tmux_conf
fi

echo "use tmux source-file $tmux_conf to update config"
