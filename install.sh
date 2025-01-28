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

# Download installation scripts
download_scripts() {
    print_color "info" "Downloading installation scripts..."
    
    curl -fsSL "https://raw.githubusercontent.com/KazeTachinuu/config/master/installvim.sh" -o "/tmp/installvim.sh"
    curl -fsSL "https://raw.githubusercontent.com/KazeTachinuu/config/master/installzsh.sh" -o "/tmp/installzsh.sh"
    
    chmod +x "/tmp/installvim.sh" "/tmp/installzsh.sh"
}

# Main installation
main() {
    print_color "info" "Starting installation process..."
    
    # Download and run installation scripts
    download_scripts
    
    print_color "info" "Installing Vim configuration..."
    sh /tmp/installvim.sh
    
    print_color "info" "Installing Zsh configuration..."
    sh /tmp/installzsh.sh
    
    # Cleanup
    rm -f "/tmp/installvim.sh" "/tmp/installzsh.sh"
    
    print_color "success" "Installation complete! Please restart your terminal."
    
    # Start new zsh session
    if command -v zsh >/dev/null; then
        exec zsh -l
    fi
}

# Execute main function
main

