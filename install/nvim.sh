#! /bin/bash

# utility functions
check_if_installed() {
  dpkg -l $1 | grep $1 | awk '{ print $2 }' | wc -l
}


# check if required packages are installed.

# sudo
if [ `check_if_installed "sudo" 2> /dev/null` != 1 ] 
then
  echo "Installing sudo";
  apt install sudo
fi

# curl
if [ `check_if_installed "curl" 2> /dev/null` != 1 ] 
then
  echo "Installing curl";
  sudo apt install curl
fi


Refer https://github.com/neovim/neovim/blob/master/INSTALL.md

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz

echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
