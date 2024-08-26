#!/bin/bash

# Common variables
declare -a required_packages=("sudo" "curl" "ripgrep" 
    "yarn" "npm" "nodejs" "perl" "python3" "ruby-dev" "gem")

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

nvim_install() {
  # Refer https://github.com/neovim/neovim/blob/master/INSTALL.md
  local dir_venky=$1
  local nvim_path="/opt/nvim-linux64/bin"
  if [ ! -d $dir_venky ]; then
    mkdir $dir_venky
  fi
  if [ -f "$dir_venky/nvim.appimage" ]; then
    rm "$dir_venky/nvim.appimage"
    rm -rf "$dir_venky/squashfs-root"
  fi
  curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage --output-dir $dir_venky
  chmod u+x "$dir_venky/nvim.appimage" 
  if ! "$dir_venky/nvim.appimage" &> /dev/null; then
    "$dir_venky/nvim.appimage" --appimage-extract &> /dev/null
    echo "$dir_venky/squashfs-root/usr/bin"
  else
    echo $nvim_path
  fi
}

post_install_cmd() {
  echo "Please run : echo 'export PATH=\"$PATH:$1\"' >> ~/.bashrc && source ~/.bashrc"
}

nvim_providers_install() {
  # Python provider
  # python3 -m venv ~/.venky
  # source ~/.venky/bin/activate
  # python3 -m pip install --user --upgrade pynvim

  # node provider
  npm install -g neovim

  # ruby provider
  gem install neovim

  #Perl provider
  # cpanm -n Neovim:Ext
}


# OS depended installation commands
install_debian() {
  # Check if required packages are installed.
  declare -a pkgs_not_available=()
  for pkg in "${required_packages[@]}"
  do
    if [ `check_if_installed_ubuntu "$pkg" 2> /dev/null` == 0 ] 
    then
      pkgs_not_available+=("$pkg")
    fi
  done

  # Install the packages which are not installed already
  apt install "${pkgs_not_available[@]}" -y

  # Install nvim
  local nvim_path=$(nvim_install ~/.venky)

  # Install providers
  nvim_providers_install

  # Post installation message
  post_install_cmd $nvim_path
}

install_rocky() {
  # Check if required packages are installed.
  declare -a pkgs_not_available=()
  for pkg in "${required_packages[@]}"
  do
    if [ `check_if_installed_rocky "$pkg" 2> /dev/null` == 0 ] 
    then
      pkgs_not_available+=("$pkg")
    fi
  done

  # Install the packages which are not installed already
  yum install "${pkgs_not_available[@]}" -y

  # Install nvim
  local nvim_path=$(nvim_install ~/.venky)

  # Install providers
  nvim_providers_install

  # Post installation message
  post_install_cmd
}

# Check the OS type
declare osid=`get_os_id`

case "$osid" in
  "ubuntu")
    install_debian ;;
  "debian")
    install_debian ;;
  "rocky")
    install_rocky ;;
  *)
    echo "Unsupported OS id: $osid" ;;
esac
