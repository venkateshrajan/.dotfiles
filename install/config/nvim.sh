#!/bin/bash

config_dir="${0%/*}"

if [ -d "`echo ~`/.config/NvChad_Venky" ]; then
  echo "Updating NvChad"
  rm -rf "`echo ~`/.config/NvChad_Venky"
fi
git clone https://github.com/NvChad/NvChad ~/.config/NvChad_Venky

if [ -d "`echo ~`/.config/NvChad_Venky/lua/custom" ]; then
  echo "patching NvChad custom folder"
  rm -rf "`echo ~`/.config/NvChad_Venky/lua/custom"
fi
ln -s "$config_dir/../../NvChad" "`echo ~`/.config/NvChad_Venky/lua/custom"

echo -e "Please run: echo 'alias vvi=\"NVIM_APPNAME=NvChad_Venky nvim\"' >> \x24HOME/.bashrc && source \x24HOME/.bashrc"

