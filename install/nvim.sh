#!/bin/bash

exec 5> /tmp/nvim.venky.log
BASH_XTRACEFD="5"
PS4='$LINENO: '
set -x

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
LGREEN='\033[1;32m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]
  then echo -e "${RED}Please run as root${NC}"
  exit
fi

scripts_dir="${0%/*}"
source "$scripts_dir/utils.sh"

###############################################################################
# Description: Downloads the nvim appimage and extracts it
#
# Arguments:
#  $1: Install directory
#  $2: Indicates if it needs to download the stable version or old version
#     If 0, then we download the stable version
#     else, we download version 0.9.5 as it is the latest that works on GLIBC2.28
#
# Returns: the path where we extracted the nvim.appimage
###############################################################################
nvim_download() {
  # Refer https://github.com/neovim/neovim/blob/master/INSTALL.md
  local nvim_path="/opt/nvim-linux64/bin"
  download_url="https://github.com/neovim/neovim/releases/download/stable/nvim.appimage"
  if (( "$2" != "0" )); then 
    download_url="https://github.com/neovim/neovim/releases/download/v0.9.5/nvim.appimage"
  fi

  curl -LO "$download_url"
  chmod u+x ./nvim.appimage
  if ! ./nvim.appimage &> /dev/null; then
    ./nvim.appimage --appimage-extract &> /dev/null
    echo "$1/squashfs-root/usr/bin"
  else
    echo $nvim_path
  fi
}

###############################################################################
# Description: Prepares the destination directory and installs nvim
#
# Arguments:
#   $1: Install directory
#   $2: Indicates if it needs to download the stable version or old version
#     If 0, then we download the stable version
#     else, we download version 0.9.5 as it is the latest that works on GLIBC2.28
#
# Returns: Nothing
###############################################################################
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
  echo "$(nvim_download $install_dir $2)"
  cd $cur_dir
}

###############################################################################
# Description: Post installation operations
#
# Arguments:
#   $1: Nvim executable path
#
# Returns: Nothing
###############################################################################
post_install_cmd() {
  echo -e "${LGREEN}Please run:${NC} ${BLUE}echo \"export PATH=\x24PATH:$1\" >> \x24HOME/.bashrc && source \x24HOME/.bashrc${NC}"
}

###############################################################################
# Description: Installs various nvim providers
#
# Arguments: Nothing
#
# Returns: Nothing
###############################################################################
nvim_providers_install() {
  # Python provider
  # python3 -m venv $HOME/.venky
  # source $HOME/.venky/bin/activate
  # python3 -m pip install --user --upgrade pynvim

  # node provider
  npm install -g neovim

  # ruby provider
  gem install neovim

  #Perl provider
  # cpanm -n Neovim:Ext
}

#####################################
# OS depended installation commands
#####################################

###############################################################################
# Description: Installs nvim on debian
#
# Arguments: Nothing
#
# Returns: Nothing
###############################################################################
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
  local nvim_path=$(nvim_install $HOME/.venky 0)

  # Install providers
  nvim_providers_install

  # Post installation message
  post_install_cmd $nvim_path
}

###############################################################################
# Description: Installs nvim on fedora
#
# Arguments:
#   $1: Indicates if it needs to download the stable version or old version
#     If 0, then we download the stable version
#     else, we download version 0.9.5 as it is the latest that works on GLIBC2.28
#
# Returns: Nothing
###############################################################################
install_fedora() {
  # Check if required packages are installed.
  declare -a required_packages=("sudo" "curl" "ripgrep" 
     "npm" "nodejs" "perl" "python3" "ruby" "ruby-devel" "gem" "gcc")
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
      dnf install --assumeyes "${pkgs_not_available[@]}" --skip-broken
    else
      sudo dnf install -y epel-release --assumeyes
      sudo dnf install --assumeyes "${pkgs_not_available[@]}" --skip-broken
    fi
  fi

  # Install nvim
  local nvim_path=$(nvim_install $HOME/.venky $1)

  # Install providers
  nvim_providers_install

  # Post installation message
  post_install_cmd $nvim_path
}

###############################################################################
# Description: Prepares the destination directory and installs nvim
#
# Arguments: Nothing
#
# Returns: Nothing
###############################################################################
install_rocky() {
  declare versionid=`get_os_version_id`
  if [ "$versionid" -ne 8 ]
  then install_fedora 0
  else
    install_fedora 1
  fi
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
  "fedora")
    install_fedora 0 ;;
  "centos")
    install_fedora 1 ;;
  *)
    echo -e "${RED}Unsupported OS id: $osid${NC}" ;;
esac
