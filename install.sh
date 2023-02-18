#!/usr/bin/env bash

# Alacritty
rm -rf ~/.config/alacritty
ln -s "$(pwd)/alacritty" ~/.config/alacritty

# compton
rm -rf ~/.config/compton.conf
ln -s "$(pwd)/compton.conf" ~/.config/compton.conf

# i3
rm -rf ~/.config/i3
ln -s "$(pwd)/i3" ~/.config/i3

# nvim
rm -rf ~/.config/nvim
ln -s "$(pwd)/init.lua/unix" ~/.config/nvim
