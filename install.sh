#!/usr/bin/env zsh

# Alacritty
echo
if read -q "choice?Press Y/y to configure alacritty: "; then
    rm -rf ~/.config/alacritty
    ln -s "$(pwd)/alacritty" ~/.config/alacritty
fi

# compton
echo
if read -q "choice?Press Y/y to configure compton: "; then
    rm -rf ~/.config/compton.conf
    ln -s "$(pwd)/compton.conf" ~/.config/compton.conf
fi

# i3
echo
if read -q "choice?Press Y/y to configure i3: "; then
    rm -rf ~/.config/i3
    ln -s "$(pwd)/i3" ~/.config/i3
fi

# nvim
echo
if read -q "choice?Press Y/y to configure nvim: "; then
    rm -rf ~/.config/nvim
    ln -s "$(pwd)/init.lua" ~/.config/nvim
fi

# ohmyzsh
echo
if read -q "choice?Press Y/y to configure ohmyzsh: "; then
    rm -rf ~/.zshrc
    ln -s "$(pwd)/.zshrc" ~/.zshrc
    source ~/.zshrc
fi

#tmux
echo
if read -q "choice?Press Y/y to configure tmux: "; then
    rm -rf ~/.tmux.conf
    ln -s "$(pwd)/.tmux.conf" ~/.tmux.conf
    source ~/.tmux.conf
fi
