#!/bin/bash

# List of packages to install
packages=(
)

# Loop through each package and install it
for pkg in "${packages[@]}"; do
    echo "Installing $pkg..."
    sudo pacman -S --noconfirm "$pkg"
done

echo "All packages installed"
