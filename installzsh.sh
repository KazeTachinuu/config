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
        PKG_LIST="zsh git curl fzf"
    elif command -v apt-get >/dev/null; then
        PKG_INSTALL="sudo apt-get update && sudo apt-get install -y"
        PKG_LIST="zsh git curl"
    elif command -v dnf >/dev/null; then
        PKG_INSTALL="sudo dnf install -y"
        PKG_LIST="zsh git curl fzf"
    elif command -v pacman >/dev/null; then
        PKG_INSTALL="sudo pacman -Sy --noconfirm"
        PKG_LIST="zsh git curl fzf"
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

# Install Oh My Zsh framework if not present
setup_ohmyzsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_color "info" "Installing Oh My Zsh..."
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        print_color "success" "Oh My Zsh already installed, skipping..."
    fi
}

# Install/Update essential Zsh plugins
setup_plugins() {
    plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    mkdir -p "$plugins_dir"

    # Auto-suggestions plugin
    if [ ! -d "$plugins_dir/zsh-autosuggestions" ]; then
        print_color "info" "Installing zsh-autosuggestions..."
        git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "$plugins_dir/zsh-autosuggestions"
    else
        print_color "info" "Updating zsh-autosuggestions..."
        (cd "$plugins_dir/zsh-autosuggestions" && git remote update && 
         if [ "$(git status -uno | grep -c 'Your branch is behind')" -gt 0 ]; then
             git pull --quiet
             print_color "success" "Updated successfully"
         else
             print_color "success" "Already up to date"
         fi)
    fi

    # Syntax highlighting plugin
    if [ ! -d "$plugins_dir/zsh-syntax-highlighting" ]; then
        print_color "info" "Installing zsh-syntax-highlighting..."
        git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting "$plugins_dir/zsh-syntax-highlighting"
    else
        print_color "info" "Updating zsh-syntax-highlighting..."
        (cd "$plugins_dir/zsh-syntax-highlighting" && git remote update && 
         if [ "$(git status -uno | grep -c 'Your branch is behind')" -gt 0 ]; then
             git pull --quiet
             print_color "success" "Updated successfully"
         else
             print_color "success" "Already up to date"
         fi)
    fi
}

# Download personal configuration files
download_configs() {
    print_color "info" "Downloading configuration files..."
    
    # Always update .zshrc
    print_color "info" "Updating .zshrc..."
    curl -fsSL "https://raw.githubusercontent.com/KazeTachinuu/config/master/.zshrc" -o "$HOME/.zshrc"
    
    # Only download .zsh_profile if it doesn't exist
    if [ ! -f "$HOME/.zsh_profile" ]; then
        print_color "info" "Downloading .zsh_profile..."
        curl -fsSL "https://raw.githubusercontent.com/KazeTachinuu/config/master/.zsh_profile" -o "$HOME/.zsh_profile"
    else
        print_color "warning" "Keeping existing .zsh_profile..."
    fi
    
    # Only download .my_aliases.txt if it doesn't exist
    if [ ! -f "$HOME/.my_aliases.txt" ]; then
        print_color "info" "Downloading .my_aliases.txt..."
        curl -fsSL "https://raw.githubusercontent.com/KazeTachinuu/config/master/.my_aliases.txt" -o "$HOME/.my_aliases.txt"
    else
        print_color "warning" "Keeping existing .my_aliases.txt..."
    fi
}

# Make Zsh the default shell
set_zsh_default() {
    zsh_path=$(command -v zsh)

    # Verify zsh is installed
    if [ -z "$zsh_path" ]; then
        print_color "error" "Error: Zsh is not installed"
        return 1
    fi

    # Compare current shell with zsh path
    if [ "$SHELL" = "$zsh_path" ]; then
        print_color "success" "Zsh is already the default shell, skipping..."
    else
        print_color "info" "Setting Zsh as default shell..."
        if command -v chsh >/dev/null 2>&1; then
            chsh -s "$zsh_path"
            print_color "success" "Default shell changed to Zsh"
        else
            print_color "error" "Error: chsh command not found. Please change your default shell manually."
            return 1
        fi
    fi
}

# Main script execution
print_color "info" "Starting Zsh installation and configuration..."
install_packages
setup_ohmyzsh
setup_plugins
download_configs
set_zsh_default

print_color "success" "Installation complete! Please restart your terminal to apply changes."