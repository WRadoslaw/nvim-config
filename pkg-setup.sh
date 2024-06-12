#!/bin/bash

apt update

echo "Installing fonts"
sudo apt install wget fontconfig \
&& wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip \
&& cd ~/.local/share/fonts && unzip Meslo.zip && rm *Windows* && rm Meslo.zip && fc-cache -fv

echo "Installing Neovim"
apt install neovim

echo "Installing Ripgrep"
apt install ripgrep

echo "Installing Node"
apt install node

echo "Installing Node"
apt install tmux

echo "Looking up latest lazygit tag"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

echo "Fetching lazygit"
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

echo "Copying lazygit into /usr/local/bin"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit

lazygit --version

echo "Cleaning up"
rm -rf lazygit.tar.gz

