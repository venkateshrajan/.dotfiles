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

scripts_dir="${0%/*}"

function check_if_installed_ubuntu() {
  dpkg -l $1 | grep $1 | awk '{ if (substr($1,1,1)~/^i/) print $0 }' | wc -l
}

function check_if_installed_rocky() {
  rpm -qa | grep -w $1 | aws 'BEGIN {FS="-"} {print $1}' | wc -l
}

function get_os_id() {
  cat /etc/os-release | grep -w "ID" | awk 'BEGIN {FS="="} {print $2}' | tr -d '"'
}

function get_os_version_id() {
  cat /etc/os-release | grep -w "VERSION_ID" | 
    awk 'BEGIN {FS="="} {print $2}' | tr -d '"' |
    awk 'BEGIN {FS="."} {print $1}' 
}

###############################################################################
# Description: Installs given packages on debian
# Arguments: List of packages
# Returns: Nothing
###############################################################################
function install_packages_debian() {
  # Check if required packages are installed.
  declare -a required_packages=("$@")
  declare -a pkgs_not_available=()
  for pkg in "${required_packages[@]}"
  do
    ret=$(check_if_installed_debian "$pkg" 2> /dev/null)
    if [ $ret -eq 0 ] 
    then
      pkgs_not_available+=("$pkg")
    fi
  done

  if (( ${#pkgs_not_available[@]} == 0)); then
    echo -e "${PURPLE} Packages ${required_packages} are already installed${NC}"
    return
  fi

  # Install the packages which are not installed already
  if [[ " ${pkgs_not_available[*]} " =~ [[:space:]]sudo[[:space:]] ]]; then
    apt install "${pkgs_not_available[@]}" -y
  else
    sudo apt install "${pkgs_not_available[@]}" -y
  fi
  echo -e "${PURPLE}Installed ${pkgs_not_available[@]} successfully${NC}"
}

###############################################################################
# Description: Installs given packages on fedora
# Arguments: List of packages
# Returns: Nothing
###############################################################################
function install_packages_fedora() {
  # Check if required packages are installed.
  declare -a required_packages=("$@")
  declare -a pkgs_not_available=()
  for pkg in "${required_packages[@]}"
  do
    ret=$(check_if_installed_rocky "$pkg" 2> /dev/null)
    if [ $ret -eq 0 ] 
    then
      pkgs_not_available+=("$pkg")
    fi
  done

  if (( ${#pkgs_not_available[@]} == 0)); then
    echo -e "${PURPLE} Packages ${required_packages} are already installed${NC}"
    return
  fi

  # Install the packages which are not installed already
  if [[ " ${pkgs_not_available[*]} " =~ [[:space:]]sudo[[:space:]] ]]; then
    dnf install -y epel-release --assumeyes
    dnf install --assumeyes "${pkgs_not_available[@]}" --skip-broken
  else
    sudo dnf install -y epel-release --assumeyes
    sudo dnf install --assumeyes "${pkgs_not_available[@]}" --skip-broken
  fi
  echo -e "${PURPLE}Installed ${pkgs_not_available[@]} successfully${NC}"
}

function install_packages() {
  # Check the OS type
  declare osid=`get_os_id`
  declare -a required_packages=("$@")
  case "$osid" in
    "ubuntu")
      install_packages_debian "${required_packages[@]}" ;;
    "debian")
      install_packages_debian "${required_packages[@]}" ;;
    "rocky")
      install_packages_fedora "${required_packages[@]}" ;;
    "fedora")
      install_packages_fedora "${required_packages[@]}" ;;
    "centos")
      install_packages_fedora "${required_packages[@]}" ;;
    *)
      echo -e "${RED}Unsupported OS id: $osid${NC}" ;;
  esac
}
