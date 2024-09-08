#!/bin/bash

scripts_dir="${0%/*}"
source "$scripts_dir/utils.sh"

packages=("sudo", "git", "findutils", "dialog")
install_packages "${packages[@]}"
