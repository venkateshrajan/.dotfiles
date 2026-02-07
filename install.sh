#!/usr/bin/env zsh

set -e

DOTFILES_DIR="${0:a:h}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()    { echo -e "${PURPLE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${RED}[WARN]${NC} $1"; }

# Cross-distro package installer
install_pkg() {
    if command -v apt &>/dev/null; then
        sudo apt install -y "$@"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$@"
    else
        warn "No supported package manager found. Please install manually: $*"
        return 1
    fi
}

###########################################################################
# Build Neovim from source (when distro version is too old)
###########################################################################
install_nvim_from_source() {
    info "Installing build dependencies (cmake, ninja-build, gettext, unzip)..."
    install_pkg cmake ninja-build gettext unzip || {
        warn "Failed to install build dependencies. Cannot build Neovim from source."
        return 1
    }

    local build_dir=$(mktemp -d)
    info "Cloning Neovim stable into $build_dir..."
    if ! git clone --depth 1 --branch stable https://github.com/neovim/neovim.git "$build_dir"; then
        warn "Failed to clone Neovim repository"
        rm -rf "$build_dir"
        return 1
    fi

    info "Building Neovim (this may take a few minutes)..."
    if ! make -C "$build_dir" CMAKE_BUILD_TYPE=Release -j$(nproc); then
        warn "Neovim build failed"
        rm -rf "$build_dir"
        return 1
    fi

    # Remove old package-managed neovim to avoid conflicts
    if command -v apt &>/dev/null && dpkg -l neovim &>/dev/null 2>&1; then
        info "Removing package-managed Neovim..."
        sudo apt-get remove -y neovim neovim-runtime 2>/dev/null
    elif command -v dnf &>/dev/null && rpm -q neovim &>/dev/null 2>&1; then
        info "Removing package-managed Neovim..."
        sudo dnf remove -y neovim 2>/dev/null
    fi

    info "Installing Neovim to /usr/local..."
    if sudo make -C "$build_dir" install; then
        local new_ver=$(nvim --version | head -n1 | grep -oP 'v[\d.]+')
        success "Neovim $new_ver built and installed from source"
    else
        warn "Failed to install Neovim"
        rm -rf "$build_dir"
        return 1
    fi

    rm -rf "$build_dir"
}

###########################################################################
# Main Menu
###########################################################################
echo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   Dotfiles Installation${NC}"
echo -e "${GREEN}========================================${NC}"
echo
echo "Select what to install (space-separated numbers, or 'all'):"
echo
echo -e "${YELLOW}1)${NC} Prerequisites (oh-my-zsh, plugins, fzf, ripgrep, zoxide, lsd, tpm)"
echo -e "${YELLOW}2)${NC} Neovim (package manager or AppImage + NvChad starter + providers)"
echo -e "${YELLOW}3)${NC} Symlink configs (zshrc, tmux, alacritty, i3, compton, nvim)"
echo -e "${YELLOW}4)${NC} NvChad_Venky config"
echo -e "${YELLOW}5)${NC} Source/reload configs"
echo -e "${YELLOW}6)${NC} Configure Git (global user.name and user.email)"
echo
echo -n "Enter choice(s) [1-6] or 'all': "
read selection

# Parse selection
declare -A selected
if [[ "$selection" == "all" ]]; then
    selected[1]=1 selected[2]=1 selected[3]=1 selected[4]=1 selected[5]=1 selected[6]=1
else
    for num in ${(s: :)selection}; do
        if [[ "$num" =~ ^[1-6]$ ]]; then
            selected[$num]=1
        fi
    done
fi

###########################################################################
# Prerequisites
###########################################################################
if [[ -n "${selected[1]}" ]]; then
    echo
    echo -e "${GREEN}=== Prerequisites ===${NC}"

    # --- Core packages via package manager ---
    info "Installing core packages (git, curl, fzf, ripgrep, tmux)..."
    install_pkg git curl fzf ripgrep tmux || warn "Some core packages could not be installed"

    # --- gh (GitHub CLI) ---
    if ! command -v gh &>/dev/null; then
        info "Installing GitHub CLI (gh)..."
        if command -v apt &>/dev/null; then
            (type -p wget >/dev/null || sudo apt install -y wget) \
                && sudo mkdir -p -m 755 /etc/apt/keyrings \
                && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
                && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null \
                && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
                && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null \
                && sudo apt update && sudo apt install -y gh \
                && rm -f "$out"
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y 'dnf-command(config-manager)' \
                && sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo \
                && sudo dnf install -y gh
        else
            warn "Could not install gh. Install manually from: https://cli.github.com/"
        fi
    else
        info "gh already installed"
    fi

    # --- zoxide ---
    if ! command -v zoxide &>/dev/null; then
        info "Installing zoxide..."
        install_pkg zoxide 2>/dev/null || {
            info "Falling back to zoxide installer script..."
            curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
        }
    else
        info "zoxide already installed"
    fi

    # --- lsd ---
    if ! command -v lsd &>/dev/null; then
        info "Installing lsd..."
        install_pkg lsd 2>/dev/null || warn "lsd not in package manager. Install from: https://github.com/lsd-rs/lsd/releases"
    else
        info "lsd already installed"
    fi

    # --- oh-my-zsh ---
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        info "oh-my-zsh already installed"
    fi

    # --- zsh plugins ---
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
    else
        info "zsh-autosuggestions already installed"
    fi

    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting"
    else
        info "zsh-syntax-highlighting already installed"
    fi

    # --- tpm (tmux plugin manager) ---
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        info "Installing tmux plugin manager (tpm)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        info "tpm already installed"
    fi

    success "Prerequisites installed"
fi

###########################################################################
# Neovim installation
###########################################################################
if [[ -n "${selected[2]}" ]]; then
    echo
    echo -e "${GREEN}=== Neovim Installation ===${NC}"

    # Check if nvim is already installed and get version
    if command -v nvim &>/dev/null; then
        local nvim_version=$(nvim --version | head -n1 | grep -oP 'v\d+\.\d+\.\d+')
        info "Found nvim $nvim_version"
    fi

    NVIM_MIN_MAJOR=0
    NVIM_MIN_MINOR=11

    # Try package manager first
    info "Attempting to install nvim via package manager..."
    if install_pkg neovim 2>/dev/null; then
        success "Neovim installed via package manager"
    else
        # Fallback to AppImage
        info "Package manager failed, downloading nvim AppImage..."

        mkdir -p "$HOME/.local/bin"
        cd "$HOME/.local/bin"

        # Remove old AppImage if it exists
        [[ -f nvim.appimage ]] && rm nvim.appimage

        # Download stable AppImage
        if curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage; then
            chmod u+x nvim.appimage

            # Try to run it to see if it works directly
            if ./nvim.appimage --version &>/dev/null; then
                ln -sf "$HOME/.local/bin/nvim.appimage" "$HOME/.local/bin/nvim"
                success "Neovim AppImage installed to ~/.local/bin/nvim"
            else
                # Extract if FUSE is not available
                info "Extracting AppImage (FUSE not available)..."
                ./nvim.appimage --appimage-extract &>/dev/null
                ln -sf "$HOME/.local/bin/squashfs-root/usr/bin/nvim" "$HOME/.local/bin/nvim"
                success "Neovim extracted to ~/.local/bin"
            fi

            # Check if ~/.local/bin is in PATH
            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                warn "Add ~/.local/bin to your PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
            fi
        else
            warn "Failed to download nvim AppImage. Install manually from: https://github.com/neovim/neovim/releases"
        fi

        cd "$DOTFILES_DIR"
    fi

    # Version check — build from source if installed version is below minimum
    if command -v nvim &>/dev/null; then
        local ver_line=$(nvim --version | head -n1)
        local cur_major=$(echo "$ver_line" | grep -oP 'v\K\d+(?=\.)')
        local cur_minor=$(echo "$ver_line" | grep -oP 'v\d+\.\K\d+(?=\.)')

        if (( cur_major < NVIM_MIN_MAJOR || (cur_major == NVIM_MIN_MAJOR && cur_minor < NVIM_MIN_MINOR) )); then
            warn "Neovim v${cur_major}.${cur_minor} is too old (need >= ${NVIM_MIN_MAJOR}.${NVIM_MIN_MINOR}). Building from source..."
            install_nvim_from_source
        else
            success "Neovim v${cur_major}.${cur_minor} meets minimum version requirement"
        fi
    fi

    # Install NvChad starter
    if command -v nvim &>/dev/null; then
        echo
        if read -q "choice?Press Y/y to install NvChad starter to ~/.config/nvim: "; then
            echo
            if [[ -e "$HOME/.config/nvim" ]]; then
                warn "~/.config/nvim already exists. Remove it first if you want to install NvChad starter."
            else
                info "Installing NvChad starter..."
                git clone https://github.com/NvChad/starter "$HOME/.config/nvim"
                success "NvChad starter installed"
                info "Launch nvim to install plugins (will happen automatically)"
            fi
        fi
    fi

    # Install nvim providers
    if command -v nvim &>/dev/null; then
        # Node provider
        if command -v npm &>/dev/null; then
            info "Installing neovim node provider..."
            npm install -g neovim
        fi

        # Ruby provider
        if command -v gem &>/dev/null; then
            info "Installing neovim ruby provider..."
            gem install neovim
        fi

        success "Neovim providers installed"
    fi
fi

###########################################################################
# Symlink dotfiles
###########################################################################
if [[ -n "${selected[3]}" ]]; then
    # Ensure base directories exist
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.bkp/.config"

    echo
    echo -e "${GREEN}=== Symlink Configs ===${NC}"

    declare -A mapsrctolink
    mapsrctolink=(
        "$DOTFILES_DIR/alacritty"     ".config/alacritty"     # Alacritty
        "$DOTFILES_DIR/compton.conf"  ".config/compton.conf"  # Compton
        "$DOTFILES_DIR/i3"            ".config/i3"            # i3
        "$DOTFILES_DIR/init.lua"      ".config/nvim-init"     # nvim (init.lua config)
        "$DOTFILES_DIR/.zshrc"        ".zshrc"                # zsh
        "$DOTFILES_DIR/.tmux.conf"    ".tmux.conf"            # tmux
    )

    for k v ("${(@kv)mapsrctolink}") {
        # Skip if source doesn't exist
        if [[ ! -e "$k" ]]; then
            warn "Source $k does not exist, skipping"
            continue
        fi

        # Back up existing file/directory (skip if it's already a symlink)
        if [[ -e "$HOME/$v" && ! -L "$HOME/$v" ]]; then
            if [[ ! -e "$HOME/.bkp/$v" ]]; then
                info "Backing up $HOME/$v -> $HOME/.bkp/$v"
                mv "$HOME/$v" "$HOME/.bkp/$v"
            else
                warn "Backup already exists at $HOME/.bkp/$v, skipping backup"
            fi
        fi

        # Remove existing symlink so ln -s doesn't fail on re-runs
        [[ -L "$HOME/$v" ]] && rm "$HOME/$v"

        ln -s "$k" "$HOME/$v"
        success "Linked $k -> $HOME/$v"
    }
fi

###########################################################################
# NvChad_Venky config
###########################################################################
if [[ -n "${selected[4]}" ]]; then
    echo
    echo -e "${GREEN}=== NvChad_Venky Config ===${NC}"

    if [[ -e "$HOME/.config/NvChad_Venky" ]]; then
        warn "Removing existing $HOME/.config/NvChad_Venky"
        rm -rf "$HOME/.config/NvChad_Venky"
    fi

    ln -s "$DOTFILES_DIR/NvChad_Venky" "$HOME/.config/NvChad_Venky"
    success "Linked NvChad_Venky config"
    info "Launch with: NVIM_APPNAME=NvChad_Venky nvim"
fi

###########################################################################
# Source configurations
###########################################################################
if [[ -n "${selected[5]}" ]]; then
    echo
    echo -e "${GREEN}=== Source Configs ===${NC}"

    if [[ -f "$HOME/.zshrc" ]]; then
        info "Sourcing .zshrc..."
        source "$HOME/.zshrc" 2>/dev/null || warn "Could not source .zshrc (may need interactive shell)"
    fi
    if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null 2>&1; then
        info "Reloading tmux config..."
        tmux source-file "$HOME/.tmux.conf" || warn "Could not reload tmux config"
    else
        warn "Tmux server not running, skipping tmux reload"
    fi
fi

###########################################################################
# Configure Git
###########################################################################
if [[ -n "${selected[6]}" ]]; then
    echo
    echo -e "${GREEN}=== Configure Git ===${NC}"

    local current_name=$(git config --global user.name 2>/dev/null)
    local current_email=$(git config --global user.email 2>/dev/null)

    if [[ -n "$current_name" ]]; then
        info "Current git user.name: $current_name"
    fi
    if [[ -n "$current_email" ]]; then
        info "Current git user.email: $current_email"
    fi

    echo -n "Enter git user.name [${current_name:-}]: "
    read git_name
    echo -n "Enter git user.email [${current_email:-}]: "
    read git_email

    if [[ -n "$git_name" ]]; then
        git config --global user.name "$git_name"
        success "Set git user.name to: $git_name"
    elif [[ -n "$current_name" ]]; then
        info "Keeping existing git user.name: $current_name"
    else
        warn "No git user.name set"
    fi

    if [[ -n "$git_email" ]]; then
        git config --global user.email "$git_email"
        success "Set git user.email to: $git_email"
    elif [[ -n "$current_email" ]]; then
        info "Keeping existing git user.email: $current_email"
    else
        warn "No git user.email set"
    fi
fi

echo
success "Done!"
