#!/bin/sh

# Color definitions
print_color() {
    case $1 in
        "info") printf "\033[36m%s\033[0m\n" "$2" ;;    # Cyan for info
        "success") printf "\033[32m%s\033[0m\n" "$2" ;; # Green for success
        "warning") printf "\033[33m%s\033[0m\n" "$2" ;; # Yellow for warning
        "error") printf "\033[31m%s\033[0m\n" "$2" ;;   # Red for error
    esac
}

# Install required packages based on available package manager
install_packages() {
    print_color "info" "Checking for required packages..."
    
    # Detect package manager
    if command -v brew >/dev/null; then
        PKG_INSTALL="brew install"
        PKG_LIST="vim git curl clang-format"
    elif command -v apt-get >/dev/null; then
        PKG_INSTALL="sudo apt-get update && sudo apt-get install -y"
        PKG_LIST="vim git curl clang-format"
    elif command -v dnf >/dev/null; then
        PKG_INSTALL="sudo dnf install -y"
        PKG_LIST="vim git curl clang-format"
    elif command -v pacman >/dev/null; then
        PKG_INSTALL="sudo pacman -Sy --noconfirm"
        PKG_LIST="vim git curl clang-format"
    else
        print_color "error" "No supported package manager found (brew/apt-get/dnf/pacman)"
        exit 1
    fi

    # Install missing packages
    for pkg in $PKG_LIST; do
        if ! command -v $pkg >/dev/null; then
            print_color "info" "Installing $pkg..."
            $PKG_INSTALL $pkg
        else
            print_color "success" "$pkg already installed"
        fi
    done
}

# Setup Vim directories
setup_directories() {
    print_color "info" "Setting up Vim directories..."
    
    # Create undo directory
    if [ ! -d "$HOME/.vimundo" ]; then
        mkdir -p "$HOME/.vimundo"
        print_color "success" "Created ~/.vimundo directory"
    fi

    # Create plugin directories
    mkdir -p "$HOME/.vim/bundle"
    mkdir -p "$HOME/.vim/pack/tpope/start"
}

# Install Vundle and plugins
setup_vundle() {
    print_color "info" "Setting up Vundle..."
    
    # Install/Update Vundle
    if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
        print_color "info" "Installing Vundle..."
        git clone --quiet https://github.com/VundleVim/Vundle.vim.git "$HOME/.vim/bundle/Vundle.vim"
    else
        print_color "info" "Updating Vundle..."
        (cd "$HOME/.vim/bundle/Vundle.vim" && git pull --quiet)
    fi

    # Install vim-commentary
    if [ ! -d "$HOME/.vim/pack/tpope/start/commentary" ]; then
        print_color "info" "Installing vim-commentary..."
        git clone --quiet https://tpope.io/vim/commentary.git "$HOME/.vim/pack/tpope/start/commentary"
    else
        print_color "info" "Updating vim-commentary..."
        (cd "$HOME/.vim/pack/tpope/start/commentary" && git pull --quiet)
    fi
}

# Download Vim configuration
download_configs() {
    print_color "info" "Downloading Vim configuration..."
    
    # Backup existing .vimrc if it exists
    if [ -f "$HOME/.vimrc" ]; then
        print_color "warning" "Backing up existing .vimrc..."
        cp "$HOME/.vimrc" "$HOME/.vimrc.backup"
    fi
    
    # Download new .vimrc
    curl -fsSL "https://raw.githubusercontent.com/KazeTachinuu/config/master/.vimrc" -o "$HOME/.vimrc"
    print_color "success" "Downloaded .vimrc successfully"
}

# Install Vim plugins using Vundle
install_plugins() {
    print_color "info" "Installing Vim plugins..."
    vim +PluginInstall +qall
    print_color "success" "Vim plugins installed successfully"
}

# Main script execution
print_color "info" "Starting Vim installation and configuration..."
install_packages
setup_directories
setup_vundle
download_configs
install_plugins

print_color "success" "Installation complete! Vim is ready to use."
