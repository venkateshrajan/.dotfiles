#!/bin/bash

config_dir="${0%/*}"

if [ -d "`echo ~`/.config/NvChad_Venky" ]; then
  echo "Updating NvChad"
  rm -rf "`echo ~`/.config/NvChad_Venky"
fi
git clone https://github.com/NvChad/starter ~/.config/NvChad_Venky

if [ -d "`echo ~`/.config/NvChad_Venky/lua/custom" ]; then
  echo "patching NvChad custom folder"
  rm -rf "`echo ~`/.config/NvChad_Venky/lua/custom"
fi

ln -s -r "$config_dir/../../NvChad" "`echo ~`/.config/NvChad_Venky/lua/custom"

GREEN='\033[0;32m'
NC='\033[0m'
echo -e "${GREEN}Please run:${NC} echo 'alias vvi=\"NVIM_APPNAME=NvChad_Venky nvim\"' >> \x24HOME/.bashrc && source \x24HOME/.bashrc"

