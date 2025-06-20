#!/bin/bash

set -e

echo "--------------------------------------------"
echo "Updating and installing apt packages..."
echo "--------------------------------------------"
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    git python3 make gcc picocom zsh \
    terminator btop neovim bat wget \
    curl snapd ranger vlc stow gnupg

echo "--------------------------------------------"
echo "Installing Snap packages..."
echo "--------------------------------------------"
sudo snap install spotify
sudo snap install code --classic
sudo snap install brave
sudo snap install thunderbird

echo "--------------------------------------------"
echo "Ensuring ~/git directory exists..."
echo "--------------------------------------------"
mkdir -p ~/git

echo "--------------------------------------------"
echo "Linking config files with stow..."
echo "--------------------------------------------"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
stow zsh p10k nvim

echo "--------------------------------------------"
echo "Setting Zsh as the default shell..."
echo "--------------------------------------------"
chsh -s "$(which zsh)"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "--------------------------------------------"
    echo "Installing Oh My Zsh..."
    echo "--------------------------------------------"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    echo "--------------------------------------------"
    echo "Installing Powerlevel10k theme..."
    echo "--------------------------------------------"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"

echo "--------------------------------------------"
echo "Installing Zsh plugins..."
echo "--------------------------------------------"
[ ! -d "$ZSH_CUSTOM/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/zsh-autosuggestions"

[ ! -d "$ZSH_CUSTOM/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/zsh-syntax-highlighting"

echo "--------------------------------------------"
echo "Creating GPG key..."
echo "--------------------------------------------"
read -rp "Enter your email for the GPG key: " GPG_EMAIL

gpg --batch --gen-key <<EOF
%no-protection
Key-Type: default
Key-Length: 4096
Subkey-Type: default
Name-Real: $USER
Name-Email: $GPG_EMAIL
Expire-Date: 0
%commit
EOF

echo "--------------------------------------------"
echo "Your GPG public key (add this to GitHub):"
echo "--------------------------------------------"
gpg --armor --export "$GPG_EMAIL"

echo "--------------------------------------------"
echo "Setup complete. Restart your terminal to apply changes."
echo "--------------------------------------------"

