#!/usr/bin/env bash

# install-tools.sh

set -e

# Detect package manager
if command -v apt >/dev/null; then
    sudo apt update
    sudo apt install -y ffmpeg python3-pip
elif command -v pacman >/dev/null; then
    sudo pacman -S ffmpeg python-pip
elif command -v dnf >/dev/null; then
    sudo dnf install -y ffmpeg python3-pip
fi

# Install subliminal
pip3 install --user subliminal

# Install alass
mkdir -p ~/.local/bin
curl -L https://github.com/kaegi/alass/releases/latest/download/alass-cli-linux \
    -o ~/.local/bin/alass-cli

chmod +x ~/.local/bin/alass-cli

# Ensure PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

echo "Done. Restart shell."
