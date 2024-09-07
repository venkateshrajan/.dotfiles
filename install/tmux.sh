#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
LGREEN='\033[1;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

config_dir="${0%/*}"

if [ -d "`echo ~`/.tmux/plugins/tpm" ]; then
  echo -e "${PURPLE}Updating tpm${NC}"
  rm -rf "`echo ~`/.tmux/plugins/tpm"
fi
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

