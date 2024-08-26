#!/bin/bash

# Utility functions
check_if_installed_ubuntu() {
  dpkg -l $1 | grep $1 | awk '{ print $2 }' | wc -l
}

check_if_installed_rocky() {
  rpm -qa | grep -w $1 | aws 'BEGIN {FS="-"} {print $1}' | wc -l
}

get_os_id() {
  cat /etc/os-release | grep -w "ID" | awk 'BEGIN {FS="="} {print $2}' | tr -d '"'
}

# OS depended installation commands
install_ubuntu() {
  # Check if required packages are installed.
  declare -a required_packages=("sudo" "curl" "ripgrep" 
      "yarn" "npm" "perl" "python3" "ruby" "gem")
  declare -a pkgs_not_available=()
  for pkg in "${required_packages[@]}"
  do
    if [ `check_if_installed_ubuntu "$pkg" 2> /dev/null` == 0 ] 
    then
      pkgs_not_available+=("$pkg")
    fi
  done

  # Install the packages which are not installed already
  apt install "${pkgs_not_available[@]}"

  # Refer https://github.com/neovim/neovim/blob/master/INSTALL.md
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz

  echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
  echo "Please run 'source ~/.bashrc'"
}

install_rocky() {
  # Check if required packages are installed.
  declare -a required_packages=("sudo" "curl")
  declare -a pkgs_not_available=()
  for pkg in "${required_packages[@]}"
  do
    if [ `check_if_installed_rocky "$pkg" 2> /dev/null` == 0 ] 
    then
      pkgs_not_available+=("$pkg")
    fi
  done

  # Install the packages which are not installed already
  yum install "${pkgs_not_available[@]}"

  # Refer https://github.com/neovim/neovim/blob/master/INSTALL.md
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz

  echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
  echo "Please run 'source ~/.bashrc'"
}

# Check the OS type
declare osid=`get_os_id`

case "$osid" in
  "ubuntu")
    install_ubuntu ;;
  "debian")
    install_ubuntu ;;
  "rocky")
    install_rocky ;;
  *)
    echo "Unsupported OS id: $osid" ;;
esac
