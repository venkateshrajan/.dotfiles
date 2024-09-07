#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
PURPLE='\033[0;35m'
NC='\033[0m'
config_dir="${0%/*}"

if [ -d "`echo ~`/.config/NvChad_Venky" ]; then
  echo "${PURPLE}Updating NvChad${NC}"
  rm -rf "`echo ~`/.config/NvChad_Venky"
fi
git clone https://github.com/NvChad/starter ~/.config/NvChad_Venky

if [ -d "`echo ~`/.config/NvChad_Venky/lua/custom" ]; then
  echo "${PURPLE}patching NvChad custom folder${NC}"
  rm -rf "`echo ~`/.config/NvChad_Venky/lua/custom"
fi

ln -s -r "$config_dir/../../NvChad" "`echo ~`/.config/NvChad_Venky/lua/custom"
echo -e "${GREEN}Please run:${NC} ${LGREEN}echo 'alias vvi=\"NVIM_APPNAME=NvChad_Venky nvim\"' >> \x24HOME/.bashrc && source \x24HOME/.bashrc${NC}"

