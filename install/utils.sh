#!/bin/bash

check_if_installed_ubuntu() {
  dpkg -l $1 | grep $1 | awk '{ print $2 }' | wc -l
}

check_if_installed_rocky() {
  rpm -qa | grep -w $1 | aws 'BEGIN {FS="-"} {print $1}' | wc -l
}

get_os_id() {
  cat /etc/os-release | grep -w "ID" | awk 'BEGIN {FS="="} {print $2}' | tr -d '"'
}

get_os_version_id() {
  cat /etc/os-release | grep -w "VERSION_ID" | 
    awk 'BEGIN {FS="="} {print $2}' | tr -d '"' |
    awk 'BEGIN {FS="."} {print $1}' 
}
