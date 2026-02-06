#!/bin/bash

scripts_dir="${0%/*}"
source "$scripts_dir/utils.sh"

install_packages "tmux"

if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  echo -e "${PURPLE}Updating tpm${NC}"
  rm -rf "$HOME/.tmux/plugins/tpm"
fi
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
