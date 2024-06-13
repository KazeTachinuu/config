#!/bin/sh

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

packagesNeeded="vim zsh git curl"

install_packages() {
    package_manager=$1
    echo -e "${YELLOW}Installing packages using $package_manager...${NC}"
    case $package_manager in
        apk)
            sudo apk add --no-cache $packagesNeeded
            ;;
        apt-get)
            sudo apt-get update && sudo apt-get install -y $packagesNeeded
            ;;
        dnf)
            sudo dnf install -y $packagesNeeded
            ;;
        zypper)
            sudo zypper install -y $packagesNeeded
            ;;
        pacman)
            sudo pacman -Syu --noconfirm $packagesNeeded
            ;;
        *)
            echo -e "${RED}FAILED TO INSTALL PACKAGES: Unsupported package manager.${NC}" >&2
            return 1
            ;;
    esac
    echo -e "${GREEN}Packages installed successfully.${NC}"
}

change_default_shell() {
    shell=$1
    if command -v $shell >/dev/null 2>&1; then
        echo -e "${YELLOW}Changing default shell to $shell...${NC}"
        chsh -s "$(which $shell)"
        echo -e "${GREEN}Default shell changed to $shell.${NC}"
    else
        echo -e "${RED}Shell $shell not found.${NC}" >&2
        return 1
    fi
}

install_vundle() {
    echo -e "${YELLOW}Installing Vundle Vim Plugin Manager...${NC}"
    if git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim; then
        echo -e "${GREEN}Vundle installed successfully.${NC}"
    else
        echo -e "${RED}Failed to install Vundle.${NC}" >&2
        return 1
    fi
}

update_vimrc() {
    echo -e "${YELLOW}Updating vimrc...${NC}"
    mkdir -p "$HOME/.vimundo"
    if curl -fsSL https://raw.githubusercontent.com/KazeTachinuu/config/master/.vimrc -o "$HOME/.vimrc"; then
        echo -e "${GREEN}vimrc updated successfully.${NC}"
    else
        echo -e "${RED}Failed to update vimrc.${NC}" >&2
        return 1
    fi
}

install_oh_my_zsh() {
    echo -e "${YELLOW}Installing Oh-My-Zsh...${NC}"
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sed '/\s*exec\s\s*zsh\s*-l\s*/d')" --unattended --skip-chsh; then
        echo -e "${GREEN}Oh-My-Zsh installed successfully.${NC}"
    else
        echo -e "${RED}Failed to install Oh-My-Zsh.${NC}" >&2
        return 1
    fi
}

update_zshrc() {
    echo -e "${YELLOW}Updating zshrc...${NC}"
    if curl -fsSL https://raw.githubusercontent.com/KazeTachinuu/config/master/.zshrc -o "$HOME/.zshrc"; then
        echo -e "${GREEN}zshrc updated successfully.${NC}"
    else
        echo -e "${RED}Failed to update zshrc.${NC}" >&2
        return 1
    fi
}

install_zsh_plugins() {
    ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    echo -e "${YELLOW}Installing zsh-autosuggestions...${NC}"
    if git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"; then
        echo -e "${GREEN}zsh-autosuggestions installed successfully.${NC}"
    else
        echo -e "${RED}Failed to install zsh-autosuggestions.${NC}" >&2
        return 1
    fi

    echo -e "${YELLOW}Installing zsh-syntax-highlighting...${NC}"
    if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; then
        echo "source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "${ZDOTDIR:-$HOME}/.zshrc"
        echo -e "${GREEN}zsh-syntax-highlighting installed successfully.${NC}"
    else
        echo -e "${RED}Failed to install zsh-syntax-highlighting.${NC}" >&2
        return 1
    fi
}

main() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}This script must be run as root for package installation.${NC}" >&2
        exit 1
    fi

    if [ -x "$(command -v apk)" ]; then
        install_packages apk || exit 1
    elif [ -x "$(command -v apt-get)" ]; then
        install_packages apt-get || exit 1
    elif [ -x "$(command -v dnf)" ]; then
        install_packages dnf || exit 1
    elif [ -x "$(command -v zypper)" ]; then
        install_packages zypper || exit 1
    elif [ -x "$(command -v pacman)" ]; then
        install_packages pacman || exit 1
    else
        echo -e "${RED}FAILED TO INSTALL PACKAGES: Package manager not found. You must manually install: $packagesNeeded${NC}" >&2
        exit 1
    fi

    echo -e "${GREEN}Package installation completed. Please run the script as a normal user for further setup.${NC}"
}

post_install() {
    change_default_shell zsh || true
    install_vundle || true
    update_vimrc || true
    install_oh_my_zsh || true
    update_zshrc || true
    install_zsh_plugins || true

    echo -e "${GREEN}All tasks completed successfully.${NC}"
    env zsh
}

if [ "$(id -u)" -eq 0 ]; then
    main
else
    post_install
fi
