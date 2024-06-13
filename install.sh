#!/bin/sh

# Define colors for colorful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# List of packages to be installed
packagesNeeded="vim zsh git curl"

# Function to check if a package is installed
package_installed() {
    package=$1
    case $package_manager in
        apk) apk info $package >/dev/null 2>&1 ;;
        apt-get) dpkg -l | grep -w "^ii  $package" >/dev/null 2>&1 ;;
        dnf) rpm -q $package >/dev/null 2>&1 ;;
        zypper) rpm -q $package >/dev/null 2>&1 ;;
        pacman) pacman -Qs $package >/dev/null 2>&1 ;;
        *) return 1 ;;
    esac
}

# Function to install packages based on package manager
install_packages() {
    package_manager=$1
    printf "${YELLOW}Installing packages using $package_manager...${NC}\n"
    for package in $packagesNeeded; do
        if ! package_installed $package; then
            case $package_manager in
                apk) sudo apk add --no-cache $package ;;
                apt-get) sudo apt-get update && sudo apt-get install -y $package ;;
                dnf) sudo dnf install -y $package ;;
                zypper) sudo zypper install -y $package ;;
                pacman) sudo pacman -Syu --noconfirm $package ;;
                *) printf "${RED}FAILED TO INSTALL $package: Unsupported package manager.${NC}\n" >&2; return 1 ;;
            esac
        else
            printf "${GREEN}$package is already installed.${NC}\n"
        fi
    done
    printf "${GREEN}Packages installed successfully.${NC}\n"
}

# Function to change the default shell
change_default_shell() {
    shell=$1
    if command -v $shell >/dev/null 2>&1; then
        if [ "$SHELL" != "$(command -v $shell)" ]; then
            printf "${YELLOW}Changing default shell to $shell...${NC}\n"
            chsh -s "$(command -v $shell)"
            printf "${GREEN}Default shell changed to $shell.${NC}\n"
        else
            printf "${GREEN}Default shell is already set to $shell.${NC}\n"
        fi
    else
        printf "${RED}Shell $shell not found.${NC}\n" >&2
        return 1
    fi
}

# Function to check if a directory exists
directory_exists() {
    directory=$1
    [ -d "$directory" ]
}

# Function to clone repositories or download files if not already present
fetch_and_install() {
    url=$1
    target=$2
    printf "${YELLOW}Fetching $url and installing to $target...${NC}\n"
    if ! directory_exists $target; then
        if git clone --quiet $url $target; then
            printf "${GREEN}Installation to $target completed.${NC}\n"
        else
            printf "${RED}Failed to fetch $url.${NC}\n" >&2
            return 1
        fi
    else
        printf "${GREEN}$target already exists.${NC}\n"
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
    printf "${YELLOW}vimrc updated.${NC}\n"

    # Install Oh-My-Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sed '/\s*exec\s\s*zsh\s*-l\s*/d')" --unattended --skip-chsh || true

    # Download and update .zshrc
    curl -fsSL https://raw.githubusercontent.com/KazeTachinuu/config/master/.zshrc -o $HOME/.zshrc
    printf "${YELLOW}zshrc updated.${NC}\n"

    # Install zsh plugins (zsh-autosuggestions and zsh-syntax-highlighting)
    fetch_and_install https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true
    fetch_and_install https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.local/share/zsh/plugins/zsh-syntax-highlighting || true

    # Install useful aliases
    if [ ! -f "$HOME/.my_aliases.txt" ]; then
        fetch_and_install https://raw.githubusercontent.com/KazeTachinuu/config/master/.my_aliases.txt $HOME/.my_aliases.txt || true
    else
        printf "${YELLOW}File $HOME/.my_aliases.txt already exists and is not empty.${NC}\n"
    fi

    # Notify completion
    printf "${GREEN}All tasks completed successfully.${NC}\n"
    env zsh  # Start zsh shell
}

# Execute main function
main
