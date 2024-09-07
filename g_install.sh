#!/bin/bash
dotfiles_root="${0%/*}"

install_nvim() {
  cd "$dotfiles_root/install"
  ./install.sh
  cd -
}

configure_nvim() {
  echo "Configure nvim"
}

install_tmux() {
  echo "Install tmux"
}

configure_tmux() {
  echo "Configure tmux"
}

declare -a options=(
  "i_nvim" "'Install nvim'" "off"
  "c_nvim" "'Configure nvim'" "off"
  "i_tmux" "'Install tmux'" "off"
  "c_tmux" "'Configure tmux'" "off"
)

tmp=$(mktemp)
eval dialog --no-tags --checklist \"Select one or more:\" 15 40 10 ${options[@]} 2> $tmp
read -a selected <<< $(cat $tmp)
clear

for item in "${selected[@]}"
do
  item=$(echo "$item" | xargs)
  case "$item" in
    "i_nvim")
      install_nvim ;;
    "c_nvim")
      configure_nvim ;;
    "i_tmux")
      install_tmux ;;
    "c_tmux")
      configure_tmux ;;
    *)
      echo "Unsupported option: $item" ;;
  esac
done

