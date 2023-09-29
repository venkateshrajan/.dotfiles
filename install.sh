#!/usr/bin/env zsh

declare -A mapsrctolink
mapsrctolink=( 
    "`pwd`/alacritty" ".config/alacritty" # Alacritty
    "`pwd`/compton.conf" ".config/compton.conf"  # Compton
    "`pwd`/i3" ".config/i3" # i3
    "`pwd`/init.lua" ".config/nvim" #nvim
    "`pwd`/.zshrc" ".zshrc" #zsh
    "`pwd`/.tmux.conf" ".tmux.conf" #tmux
)

for k v ("${(@kv)mapsrctolink}") {
    echo
    if read -q "choice?Press Y/y to config $k -> `echo ~`/$v: "; then
        echo
        if [ ! -d "`echo ~`/.bkp/.config" ]; then
            echo "Creating `echo ~`/.bkp/.config"
            mkdir -p `echo ~`/.bkp/.config
        fi

        if [ ! -d "`echo ~`/.bkp/$v" ] && [ ! -f "`echo ~`/.bkp/$v" ]; then
            if [ -d "`echo ~`/$v" ] || [ -f "`echo ~`/$v" ]; then
                echo "Backing up `echo ~`/$v"
                mv "`echo ~`/$v" "`echo ~`/.bkp/$v"
            fi
        fi

        ln -s "$k" "`echo ~`/$v"
    fi
}

echo
if read -q "choice?Press Y/y to source the configurations: "; then
    source ~/.zshrc
    tmux source ~/.tmux.conf
fi

echo
