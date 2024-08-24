#!/bin/bash

# utility functions
check_if_installed() {
  dpkg -l $1 | grep $1 | awk '{ print $2 }' | wc -l
}


# check if required packages are installed.
declare -a required_packages=("sudo" "curl")
declare -a pkgs_not_available=()
for pkg in "${required_packages[@]}"
do
  if [ `check_if_installed "$pkg" 2> /dev/null` != 1 ] 
  then
    pkgs_not_available+=("$pkg")
  fi
done

# install the packages which are not installed already
for pkg in "${pkgs_not_available[@]}"
do
  apt install "$pkg"
done

#Refer https://github.com/neovim/neovim/blob/master/INSTALL.md
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz

echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
source ~/.bashrc
