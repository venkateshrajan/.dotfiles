#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

config_dir="${0%/*}"

if [ -f "`echo ~`/.tmux-venky.conf" ]; then
  echo -e "${PURPLE}patching tmux config${NC}"
  rm -rf "`echo ~`/.tmux-venky.conf"
fi

ln -s -r "$config_dir/../../.tmux.conf" "`echo ~`/.tmux-venky.conf"
ln -s -r "$config_dir/../../.tmux.conf" "`echo ~`/.tmux.conf"
echo -e "${LGREEN}Please run:${NC} ${BLUE}echo 'alias vtmux=\"tmux -L venky -f \x24HOME/.tmux-venky.conf\"' >> \x24HOME/.bashrc && source \x24HOME/.bashrc${NC}"
