#!/bin/sh

# Define colors for colorful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


# List of packages to be installed
PACKAGES="zsh"

# Function to install packages based on package manager
install_packages() {
    package_manager=$1
    echo -e "${YELLOW}Installing packages using $package_manager...${NC}"
    case $package_manager in
        apk) sudo apk add --no-cache $packagesNeeded ;;
        apt-get) sudo apt-get update && sudo apt-get install -y $packagesNeeded ;;
        dnf) sudo dnf install -y $packagesNeeded ;;
        zypper) sudo zypper install -y $packagesNeeded ;;
        pacman) sudo pacman -Sy --noconfirm $packagesNeeded ;;
        *) echo -e "${RED}FAILED TO INSTALL PACKAGES: Unsupported package manager.${NC}" >&2; return 1 ;;
    esac
    echo -e "${GREEN}Packages installed successfully.${NC}"
}


# Function to fetch and install if not already present
fetch_and_install() {
    url=$1
    target=$2
    echo -e "${YELLOW}Fetching $url and installing to $target...${NC}"
    [ -d "$target" ] && rm -rf "$target"
    git clone --quiet "$url" "$target"
    echo -e "${GREEN}Installation to $target completed.${NC}"
}

# Main installation function
main() {

    # Check which package manager is available and install necessary packages
    for manager in apk apt-get dnf zypper pacman; do
        command -v "$manager" >/dev/null 2>&1 && install_packages "$manager" && break
    done

    # Create ~/.vimundo directory
    if [ ! -d "$HOME/.vimundo" ]; then
        echo -e "${YELLOW}Creating ~/.vimundo directory...${NC}"
        mkdir -p "$HOME/.vimundo"
        echo -e "${GREEN}~/.vimundo directory created successfully.${NC}"
    fi

    # Install Vundle Vim Plugin Manager
    fetch_and_install "https://github.com/VundleVim/Vundle.vim.git" "$HOME/.vim/bundle/Vundle.vim"

    # Download and update .vimrc
    echo -e "${YELLOW}Updating vimrc...${NC}"
    curl -fsSL "https://raw.githubusercontent.com/KazeTachinuu/config/master/.vimrc" -o "$HOME/.vimrc"
    echo -e "${GREEN}vimrc updated successfully.${NC}"

    # Create Vim plugin directory and clone vim-commentary plugin
    echo -e "${YELLOW}Installing vim-commentary plugin...${NC}"
    mkdir -p "$HOME/.vim/pack/tpope/start/commentary"
    fetch_and_install "https://tpope.io/vim/commentary.git" "$HOME/.vim/pack/tpope/start/commentary"
    echo -e "${GREEN}vim-commentary plugin installed successfully.${NC}"

    # Notify completion
    echo -e "${GREEN}All tasks completed successfully.${NC}"
}

# Execute main function
main
