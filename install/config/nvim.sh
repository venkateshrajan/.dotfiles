#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'
config_dir="${0%/*}"

if [ -d "`echo ~`/.config/NvChad_Venky" ]; then
  >&2 echo -e "${PURPLE}Updating NvChad${NC}"
  rm -rf "`echo ~`/.config/NvChad_Venky"
fi

ln -s -r "$config_dir/../../NvChad_Venky" "`echo ~`/.config/NvChad_Venky"
echo -e "${LGREEN}Please run:${NC} ${BLUE}echo 'alias vvi=\"NVIM_APPNAME=NvChad_Venky nvim\"' >> \x24HOME/.bashrc && source \x24HOME/.bashrc${NC}"

