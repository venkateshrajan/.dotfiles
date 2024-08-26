#!/bin/bash

exec 5> /tmp/nvim.venky.log
BASH_XTRACEFD="5"
PS4='$LINENO: '
set -x

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

nvim_install_core() {
  # Refer https://github.com/neovim/neovim/blob/master/INSTALL.md
  local nvim_path="/opt/nvim-linux64/bin"
  curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
  chmod u+x ./nvim.appimage
  if ! ./nvim.appimage &> /dev/null; then
    ./nvim.appimage --appimage-extract &> /dev/null
    echo "$1/squashfs-root/usr/bin"
  else
    echo $nvim_path
  fi
}

nvim_install() {
  # Prepare the destination directory
  local install_dir=$1
  if [ ! -d $install_dir ]; then
    mkdir $install_dir
  fi
  if [ -f "$install_dir/nvim.appimage" ]; then
    rm "$install_dir/nvim.appimage"
    rm -rf "$install_dir/squashfs-root"
  fi
  # Install nvim
  local cur_dir=`pwd`
  cd $install_dir
  echo "$(nvim_install_core $install_dir)"
  cd $cur_dir
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
  sudo npm install -g neovim

  # ruby provider
  sudo gem install neovim

  #Perl provider
  # cpanm -n Neovim:Ext
}

#####################################
# OS depended installation commands
#####################################

# Debian
install_debian() {
  # Check if required packages are installed.
  declare -a required_packages_debian=("sudo" "curl" "ripgrep" 
    "yarn" "npm" "nodejs" "perl" "python3" "ruby-dev" "gem")
  declare -a pkgs_not_available=()
  for pkg in "${required_packages_debian[@]}"
  do
    if [ `check_if_installed_ubuntu "$pkg" 2> /dev/null` == 0 ] 
    then
      pkgs_not_available+=("$pkg")
    fi
  done

  # Install the packages which are not installed already
  if (( ${#pkgs_not_available[@]} )); then
    if [[ " ${pkgs_not_available[*]} " =~ [[:space:]]sudo[[:space:]] ]]; then
      apt install "${pkgs_not_available[@]}" -y
    else
      sudo apt install "${pkgs_not_available[@]}" -y
    fi
  fi

  # Install nvim
  local nvim_path=$(nvim_install ~/.venky)

  # Install providers
  nvim_providers_install

  # Post installation message
  post_install_cmd $nvim_path
}

install_rocky() {
  # Check if required packages are installed.
  declare -a required_packages=("sudo" "curl" "ripgrep" 
     "npm" "nodejs" "perl" "python3" "ruby" "gem")
  declare -a pkgs_not_available=()
  for pkg in "${required_packages[@]}"
  do
    if [ `check_if_installed_rocky "$pkg" 2> /dev/null` == 0 ] 
    then
      pkgs_not_available+=("$pkg")
    fi
  done

  # Install the packages which are not installed already
  if (( ${#pkgs_not_available[@]} )); then
    if [[ " ${pkgs_not_available[*]} " =~ [[:space:]]sudo[[:space:]] ]]; then
      dnf install -y epel-release --assumeyes
      dnf install --assumeyes "${pkgs_not_available[@]}"
    else
      sudo dnf install -y epel-release --assumeyes
      sudo dnf install --assumeyes "${pkgs_not_available[@]}"
    fi
  fi

  # Install nvim
  local nvim_path=$(nvim_install ~/.venky)

  # Install providers
  nvim_providers_install

  # Post installation message
  post_install_cmd $nvim_path
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
