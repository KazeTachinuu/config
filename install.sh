#!/bin/sh

# Define colors for colorful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# List of packages to be installed
packagesNeeded="vim zsh git curl"

# Function to install packages based on package manager
install_packages() {
    package_manager=$1
    echo -e "${YELLOW}Installing packages using $package_manager...${NC}"
    case $package_manager in
        apk) sudo apk add --no-cache $packagesNeeded ;;
        apt-get) sudo apt-get update && sudo apt-get install -y $packagesNeeded ;;
        dnf) sudo dnf install -y $packagesNeeded ;;
        zypper) sudo zypper install -y $packagesNeeded ;;
        pacman) sudo pacman -Syu --noconfirm $packagesNeeded ;;
        *) echo -e "${RED}FAILED TO INSTALL PACKAGES: Unsupported package manager.${NC}" >&2; return 1 ;;
    esac
    echo -e "${GREEN}Packages installed successfully.${NC}"
}

# Function to change the default shell
change_default_shell() {
    shell=$1
    if command -v $shell >/dev/null 2>&1; then
        echo -e "${YELLOW}Changing default shell to $shell...${NC}"
        chsh -s "$(command -v $shell)"
        echo -e "${GREEN}Default shell changed to $shell.${NC}"
    else
        echo -e "${RED}Shell $shell not found.${NC}" >&2
        return 1
    fi
}

# Function to clone repositories or download files
fetch_and_install() {
    url=$1
    target=$2
    echo -e "${YELLOW}Fetching $url and installing to $target...${NC}"
    if git clone --quiet $url $target; then
        echo -e "${GREEN}Installation to $target completed.${NC}"
    else
        echo -e "${RED}Failed to fetch $url.${NC}" >&2
        return 1
    fi
}

# Main installation function
main() {
    # Check which package manager is available and install necessary packages
    for manager in apk apt-get dnf zypper pacman; do
        if command -v $manager >/dev/null 2>&1; then
            install_packages $manager || exit 1
            break
        fi
    done

    # Change default shell to zsh
    change_default_shell zsh || true

    # Install Vundle Vim Plugin Manager
    fetch_and_install https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim || true

    # Download and update .vimrc
    curl -fsSL https://raw.githubusercontent.com/KazeTachinuu/config/master/.vimrc -o $HOME/.vimrc
    echo -e "${YELLOW}vimrc updated.${NC}"

    # Install Oh-My-Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sed '/\s*exec\s\s*zsh\s*-l\s*/d')" --unattended --skip-chsh || true

    # Download and update .zshrc
    curl -fsSL https://raw.githubusercontent.com/KazeTachinuu/config/master/.zshrc -o $HOME/.zshrc
    echo -e "${YELLOW}zshrc updated.${NC}"

    # Install zsh plugins (zsh-autosuggestions and zsh-syntax-highlighting)
    fetch_and_install https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true
    fetch_and_install https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.local/share/zsh/plugins/zsh-syntax-highlighting || true

    # Install useful aliases
    fetch_and_install https://raw.githubusercontent.com/KazeTachinuu/config/master/.my_aliases.txt $HOME/.my_aliases.txt || true

    # Notify completion
    echo -e "${GREEN}All tasks completed successfully.${NC}"
    env zsh  # Start zsh shell
}

# Execute main function
main
