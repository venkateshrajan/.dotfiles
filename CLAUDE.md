# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository managing configurations for Neovim (NvChad), Zsh (Oh-My-Zsh), Tmux, Alacritty, i3 window manager, and Compton. Targets Debian/Ubuntu and Fedora/Rocky Linux systems.

## Installation

```bash
git clone --recurse-submodules <repo> && ./install.sh
```

- `install.sh` — interactive zsh-based installer that:
  - Installs prerequisites (oh-my-zsh, plugins, fzf, ripgrep, tmux, gh, zoxide, lsd, tpm)
  - Installs neovim (via package manager or AppImage) + optional NvChad starter + providers
  - Symlinks configs and backs up existing files to `~/.bkp/`
  - Configures git global user.name and user.email (interactive prompts)
  - Installs tools via sub-menu (Docker, ...)
  - NvChad starter → `~/.config/nvim`, init.lua → `~/.config/nvim-init`, NvChad_Venky → `~/.config/NvChad_Venky`
- `g_install.sh` — root-based bash installer using `dialog` for multi-step setup (alternative to install.sh)
- `install/nvim.sh`, `install/tmux.sh` — individual tool installers (require root)
- `install/utils.sh` — shared utility library (OS detection, cross-distro package management)

There is no Makefile, CI, or formal test suite. Lua files use `.stylua.toml` for formatting (in `NvChad_Venky/`).

## Architecture

### Neovim Configuration (`NvChad_Venky/`)

This is the **active** neovim config. The older `NvChad/` directory is legacy.

Built on **NvChad v2.5** with **Lazy.nvim** as the plugin manager:

- `init.lua` — entry point, bootstraps lazy.nvim
- `lua/chadrc.lua` — NvChad overrides (theme: tomorrow_night, transparency)
- `lua/options.lua` — vim options (scrolloff=8, colorcolumn=80, relative numbers)
- `lua/mappings.lua` — keybindings for Harpoon, Fugitive, terminal
- `lua/plugins/init.lua` — plugin declarations (Conform, LSP, Treesitter, Harpoon, Fugitive)
- `lua/configs/` — per-plugin configuration (LSP servers: html, cssls, clangd, rust_analyzer; Conform formatters)

NvChad_Venky is a standalone config symlinked to `~/.config/NvChad_Venky` (launched via `NVIM_APPNAME=NvChad_Venky nvim`).

### Symlink Mapping

The installer creates these symlinks (source → destination):
- `.zshrc` → `~/.zshrc`
- `.tmux.conf` → `~/.tmux.conf`
- `alacritty/` → `~/.config/alacritty`
- `i3/` → `~/.config/i3`
- `init.lua/` → `~/.config/nvim-init` (alternative nvim config, use with `NVIM_APPNAME=nvim-init nvim`)
- `NvChad_Venky` custom dir → `~/.config/NvChad_Venky`

No symlink manager (stow/chezmoi) is used — plain `ln -s` with manual backup.

### Shell Scripts

- `scripts/tmux-session-finder.sh` — FZF-based tmux session switcher (aliased as `ts` in zshrc)
- `scripts/get-diff-names.sh` — extracts modified filenames from git diff
- `install/utils.sh` — OS detection (`get_os_id`, `get_os_version_id`) and cross-distro package install dispatching

### Git Submodules

- `alacritty/alacritty-theme` — Alacritty color themes
- `init.lua` — alternative neovim config (separate project)

### Zsh Configuration

Uses Oh-My-Zsh with plugins: vi-mode, zsh-autosuggestions, zsh-syntax-highlighting, z, fzf, and others. Integrates zoxide, nvm, and custom aliases (`vi` launches NvChad, `ts` opens tmux session finder).

### Tmux Configuration

Dual prefix (Ctrl+A and Ctrl+B), TPM plugin manager, Dracula theme, FZF session switcher on Alt+J, mouse enabled.
