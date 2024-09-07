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
# Description: Clones tmux plugins manager tpm
#
# Arguments: Nothing
#
# Returns: Nothing
###############################################################################
tpm_install() {
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

#####################################
# OS depended installation commands
#####################################

###############################################################################
# Description: Installs tmux on debian
#
# Arguments: Nothing
#
# Returns: Nothing
###############################################################################
install_debian() {
  # Check if required packages are installed.
  declare -a required_packages_debian=("tmux")
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

  # Install tpm
  $(tpm_install)
}

###############################################################################
# Description: Installs tmux on fedora
#
# Arguments: Nothing
#
# Returns: Nothing
###############################################################################
install_fedora() {
  # Check if required packages are installed.
  declare -a required_packages=("tmux")
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

  # Install tpm
  $(tpm_install)
}

# Check the OS type
declare osid=`get_os_id`

case "$osid" in
  "ubuntu")
    install_debian ;;
  "debian")
    install_debian ;;
  "rocky")
    install_fedora ;;
  "fedora")
    install_fedora ;;
  "centos")
    install_fedora ;;
  *)
    echo -e "${RED}Unsupported OS id: $osid${NC}" ;;
esac
