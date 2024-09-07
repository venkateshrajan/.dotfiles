#!/bin/bash

git clone https://github.com/NvChad/NvChad ~/.config/NvChad_Venky
if [ -d "`echo ~`/.config/NvChad_Venky/lua/custom" ]; then
  echo "patching NvChad custom folder"
  rm -rf "`echo ~`/.config/NvChad_Venky/lua/custom"
fi
ln -s "`pwd`/NvChad" "`echo ~`/.config/NvChad_Venky/lua/custom"
