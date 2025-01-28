#!/bin/sh

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# List of required packages
packagesNeeded="zsh git curl fzf"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print colored messages
print_message() {
    color=$1
    message=$2
    echo -e "${color}${message}${NC}"
}

# Function to install packages based on package manager
install_packages() {
    package_manager=$1
    print_message "$YELLOW" "Installing packages using $package_manager..."
    case $package_manager in
        apk) sudo apk add --no-cache $packagesNeeded ;;
        apt-get) 
            sudo apt-get update
            sudo apt-get install -y $packagesNeeded ;;
        dnf) sudo dnf install -y $packagesNeeded ;;
        zypper) sudo zypper install -y $packagesNeeded ;;
        pacman) sudo pacman -Sy --noconfirm $packagesNeeded ;;
        brew) brew install $packagesNeeded ;;
        *) print_message "$RED" "FAILED TO INSTALL PACKAGES: Unsupported package manager." >&2; return 1 ;;
    esac
    print_message "$GREEN" "Packages installed successfully."
}

# Function to change the default shell
change_default_shell() {
    shell=$1
    if command_exists "$shell" && [ "$SHELL" != "$(command -v $shell)" ]; then
        print_message "$YELLOW" "Changing default shell to $shell..."
        sudo chsh -s "$(command -v $shell)" "$USER"
        print_message "$GREEN" "Default shell changed to $shell."
    else
        print_message "$YELLOW" "Shell $shell is already set as default."
    fi
}

# Function to safely download files
download_file() {
    url=$1
    target=$2
    print_message "$YELLOW" "Downloading from $url to $target..."
    if curl -fsSL "$url" -o "$target"; then
        print_message "$GREEN" "Download completed successfully."
        return 0
    else
        print_message "$RED" "Failed to download from $url" >&2
        return 1
    fi
}

# Function to install Zsh plugins
install_plugin() {
    repo_url=$1
    install_path=$2
    plugin_name=$(basename "$install_path")
    
    print_message "$YELLOW" "Installing $plugin_name..."
    if [ -d "$install_path" ]; then
        print_message "$YELLOW" "Updating existing $plugin_name..."
        (cd "$install_path" && git pull --quiet)
    else
        git clone --quiet "$repo_url" "$install_path"
    fi
    print_message "$GREEN" "$plugin_name installed successfully."
}

# Main installation function
main() {
    # Create necessary directories
    mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$HOME/.local/share/zsh/plugins"

    # Check for and install package manager
    for manager in brew apk apt-get dnf zypper pacman; do
        if command_exists "$manager"; then
            install_packages "$manager"
            break
        fi
    done

    # Install Oh-My-Zsh if not already installed
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_message "$YELLOW" "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --skip-chsh
        print_message "$GREEN" "Oh-My-Zsh installed successfully."
    fi

    # Install Zsh plugins
    install_plugin "https://github.com/zsh-users/zsh-autosuggestions" \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    
    install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

    # Download configuration files
    download_file "https://raw.githubusercontent.com/KazeTachinuu/config/master/.zshrc" \
        "$HOME/.zshrc"
    
    download_file "https://raw.githubusercontent.com/KazeTachinuu/config/master/.my_aliases.txt" \
        "$HOME/.my_aliases.txt"

    # Change default shell to Zsh
    change_default_shell "zsh"

    # Initialize fzf
    if command_exists fzf; then
        print_message "$YELLOW" "Initializing fzf..."
        if ! grep -q "source.*fzf.*zsh" "$HOME/.zshrc"; then
            echo "source <(fzf --zsh)" >> "$HOME/.zshrc"
        fi
        print_message "$GREEN" "fzf initialized successfully."
    fi

    print_message "$GREEN" "Installation completed successfully!"
    print_message "$YELLOW" "Please restart your terminal or run 'exec zsh' to start using your new Zsh configuration."
}

# Execute main function
main