# Venky's dotfiles
My configuration for linux

## Prerequisites

### zsh
`install.sh` is a zsh script, so zsh must be installed first:
```zsh
sudo apt install zsh   # Debian/Ubuntu
sudo dnf install zsh   # Fedora/Rocky
chsh -s $(which zsh)   # Set as default shell (re-login after)
```

## Installation
This repo has submodules so please clone it with the following command.
```zsh
git clone --recurse-submodules https://github.com/venkateshrajan/.dotfiles.git
cd .dotfiles
./install.sh
```

The install script will show a menu where you can select what to install:

```
1) Prerequisites (oh-my-zsh, plugins, fzf, ripgrep, zoxide, lsd, tpm)
2) Neovim (package manager or AppImage + NvChad starter + providers)
3) Symlink configs (zshrc, tmux, alacritty, i3, compton, nvim)
4) NvChad_Venky config
5) Source/reload configs
```

**Examples:**
- `all` — install everything
- `1 2 3` — install prerequisites, neovim, and symlink configs
- `3 4` — just symlink configs and NvChad

**Config locations:**
- **Option 2** — NvChad starter → `~/.config/nvim` (default, used by `nvim`)
- **Option 3** — init.lua submodule → `~/.config/nvim-init` (use with `NVIM_APPNAME=nvim-init nvim`)
- **Option 4** — NvChad_Venky custom → `~/.config/NvChad_Venky` (use with `vi` alias or `NVIM_APPNAME=NvChad_Venky nvim`)

All three configs are independent and can be installed simultaneously.

### After installation
- Open tmux and press `Ctrl+b` then `I` (capital i) to install tmux plugins via tpm
- Open nvim with `vi` (alias) — lazy.nvim will auto-install plugins on first launch
- Run `:checkhealth` in nvim to verify everything is working

## Optional tools

### neovim (manual installation)
If you prefer to install neovim manually instead of using the install script:
- Get the [stable release](https://github.com/neovim/neovim/releases/tag/stable)
- Or use `sudo ./g_install.sh` which downloads the AppImage and installs providers

### brew
Needed only if your package manager doesn't have fzf/zoxide/lsd. Cannot be installed as root.
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
After installing, brew will show you two commands to add it to your PATH — copy and run those.

### nvm
Node version manager, loaded by `.zshrc` if present:
```zsh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

## Troubleshooting

If you get a broken-pipe error when installing a `.deb` package:
```zsh
sudo dpkg -i --force-overwrite *.deb
sudo apt -f install
```
