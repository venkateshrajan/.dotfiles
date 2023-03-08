# Venky's dotfiles
My configuration for linux

## Prerequisites
### zsh
```zsh
sudo apt install zsh
```
### Oh-my-zsh
https://ohmyz.sh/
```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### zsh-autosuggestions
https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
```zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### neovim
https://github.com/neovim/neovim/releases/tag/stable

## Installation
This repo has submodules so please clone it with the following command.
```zsh
git clone --recurse-submodules https://github.com/venkateshrajan/.dotfiles.git
cd .dotfiles
./install.sh
```

### clone packer
```zsh
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

Check the health of nvim
```vim
:checkhealth
```

Check the version of nvim and make sure if its a latest one
```vim
:version
```

If you are getting broken-pipe error when trying to overwrite the old package with the new one
https://askubuntu.com/questions/1062171/dpkg-deb-error-paste-subprocess-was-killed-by-signal-broken-pipe


