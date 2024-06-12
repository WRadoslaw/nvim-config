#!/bin/bash

# Function to ask for confirmation
confirm() {
    # Prompt the user for confirmation
    read -r -p "${1:-Are you sure? [y/N]} " response
    # Convert the response to lowercase and check if it's "yes" or "y"
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

echo "Remember to run pkg-setup.sh on new machine"

if ! confirm "This will override your current nvim and tmux config. Do you want to proceed? [y/N]"; then
    exit 1
fi
# Copy neovim config into .config
echo "Replacing neovim config..."
rm -rf ~/.config/nvim
mkdir -p ~/.config/nvim
cp -r ./neovim/* ~/.config/nvim

# Copy tmux config into home dir
echo "Replacing tmux config..."
rm -rf ~/.tmux.conf
cp ./tmux/.tmux.conf ~/

tmux source-file ~/.tmux.conf
