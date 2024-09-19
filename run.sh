#!/bin/bash

# Check if the user is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME="$1"
FLAG_FILE="/tmp/${USERNAME}_password_flag"

# Check if the user exists
if ! id "$USERNAME" &>/dev/null; then
    echo "Error: User '$USERNAME' does not exist."
    exit 1
fi

# Check if the user has no password (password field is empty)
if sudo passwd -S "$USERNAME" | grep -q "NP"; then
    echo "User '$USERNAME' has no password set. Setting password to 'temp'..."

    # Automatically set the password to 'temp'
    echo "$USERNAME:temp" | sudo chpasswd

    if [ $? -eq 0 ]; then
        echo "Password for user '$USERNAME' has been set to 'temp'."
        
        # Create a flag file indicating that the password was set by this script
        touch "$FLAG_FILE"
    else
        echo "Failed to set password for user '$USERNAME'."
    fi
else
    echo "User '$USERNAME' already has a password set."
fi

# disable read only file system
sudo steamos-readonly disable

# initialize and populate archlinux keys
sudo pacman-key --init
sudo pacman-key --populate archlinux

# install basic missing packages
sudo pacman -S --noconfirm git
sudo pacman -S --noconfirm base-devel
sudo pacman -S --noconfirm cmake
sudo pacman -S --noconfirm ninja
sudo pacman -S --noconfirm glibc linux-api-headers
sudo pacman -Qk | grep 'warning: ' >> file.txt

# run python script for file parsing
python3 main.py

# runs final script to install missing packages
chmod 777 install_packages.sh
./install_packages.sh

#!/bin/bash

# Check if the user is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME="$1"
FLAG_FILE="/tmp/${USERNAME}_password_flag"

# Check if the flag file exists (meaning the password was set by the previous script)
if [ -f "$FLAG_FILE" ]; then
    echo "Deleting password for user '$USERNAME'..."

    # Delete the user's password (lock the account)
    sudo passwd -d "$USERNAME"

    if [ $? -eq 0 ]; then
        echo "Password for user '$USERNAME' has been deleted."

        # Remove the flag file after successfully deleting the password
        rm "$FLAG_FILE"
    else
        echo "Failed to delete the password for user '$USERNAME'."
    fi
else
    echo "Password was not set by the previous script. No action taken."
fi

# reenables steam safeguards
sudo steamos-readonly enable
