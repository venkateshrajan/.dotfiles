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

### brew
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/venky/.zprofile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```
After installing brew using the install.sh it will show you the remaining two commands with correct arguments.
Always copy those two commands from the output


## TMUX
### tpm
```zsh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
Open tmux by typing `tmux` and then `Ctrl+b+I` to install tpm plugins

### fzf
fzf is necessary for the `ts` alias
```zsh
brew install fzf
```

## NVIM
### neovim
install [stable](https://github.com/neovim/neovim/releases/tag/stable)

## Installation
This repo has submodules so please clone it with the following command.
```zsh
git clone --recurse-submodules https://github.com/venkateshrajan/.dotfiles.git
cd .dotfiles
./install.sh
```

### packer
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

If you are getting broken-pipe error when trying to overwrite the old package with the new one. Follow the [thread](https://askubuntu.com/questions/1062171/dpkg-deb-error-paste-subprocess-was-killed-by-signal-broken-pipe)

navigate to `nvim ~/.config/nvim/lua/venky/packer.lua`

Do `:source` and them `:PackerSync`. This will download all the tmux-plugins.
After the PackerSync if the colors aren't set correctly run `:lua ColorMyPencils()`


