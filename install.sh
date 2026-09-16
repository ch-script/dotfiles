#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

echo "Creating base directories"
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/Pictures/Wallpapers"

echo "Making links"
mkdir -p "$HOME/.config/quickshell"
rm -rf "$HOME/.config/quickshell/bar"
ln -sfn "$DOTFILES/shell" "$HOME/.config/quickshell/bar"

echo "Copying configs"
cp -r "$DOTFILES/configfiles/." "$HOME/.config/"

echo "Copying scripts"
cp -r "$DOTFILES/localbin/." "$HOME/.local/bin/"
chmod +x "$HOME"/.local/bin/* 2>/dev/null || true

echo "Copying wallpapers"
cp -r "$DOTFILES/wallpapers/." "$HOME/Pictures/Wallpapers/"

echo "we're set"
