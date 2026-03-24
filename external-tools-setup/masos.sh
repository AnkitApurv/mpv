#!/usr/bin/env bash

# install-tools-macos.sh

set -e

# Install Homebrew if missing
if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install ffmpeg
brew install ffmpeg python

# Install subliminal
pip3 install --user subliminal

# Install alass
mkdir -p ~/.local/bin
curl -L https://github.com/kaegi/alass/releases/latest/download/alass-cli-macos \
    -o ~/.local/bin/alass-cli

chmod +x ~/.local/bin/alass-cli

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc

echo "Done. Restart shell."
