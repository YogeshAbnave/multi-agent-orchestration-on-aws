#!/bin/bash

# Simple Ubuntu 24 EC2 User Creation Script
# Creates user 'cloudage-user' with root permissions and switches to that user

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Hardcoded username
USERNAME="cloudage-user"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root (use sudo)${NC}"
   exit 1
fi

echo -e "${GREEN}Creating user: $USERNAME${NC}"

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    echo -e "${YELLOW}User '$USERNAME' already exists${NC}"
    read -p "Continue with existing user? (y/N): " CONTINUE
    if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
    USER_EXISTS=true
else
    USER_EXISTS=false
fi

# Create user if doesn't exist
if [[ $USER_EXISTS == false ]]; then
    echo "Creating user '$USERNAME'..."
    useradd -m -s /bin/bash "$USERNAME"
    echo -e "${GREEN}User '$USERNAME' created successfully!${NC}"
fi

# Add user to sudo group and enable passwordless sudo
echo "Adding '$USERNAME' to sudo group..."
usermod -aG sudo "$USERNAME"
echo -e "${GREEN}User '$USERNAME' added to sudo group!${NC}"

echo "Enabling passwordless sudo..."
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
chmod 440 "/etc/sudoers.d/$USERNAME"
echo -e "${GREEN}Passwordless sudo enabled!${NC}"

# Setup SSH directory
echo "Setting up SSH directory..."
USER_HOME="/home/$USERNAME"
SSH_DIR="$USER_HOME/.ssh"

mkdir -p "$SSH_DIR"
chown "$USERNAME:$USERNAME" "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Copy SSH keys from ubuntu user if available
if [[ -f "/home/ubuntu/.ssh/authorized_keys" ]]; then
    echo "Copying SSH keys from ubuntu user..."
    cp "/home/ubuntu/.ssh/authorized_keys" "$SSH_DIR/authorized_keys"
    chown "$USERNAME:$USERNAME" "$SSH_DIR/authorized_keys"
    chmod 600 "$SSH_DIR/authorized_keys"
    echo -e "${GREEN}SSH keys copied!${NC}"
fi

echo -e "${GREEN}Setup completed successfully!${NC}"
echo "User '$USERNAME' configuration:"
echo "  - Home directory: $USER_HOME"
echo "  - Shell: /bin/bash"
echo "  - Sudo privileges: Yes (passwordless)"
echo "  - SSH access: Yes"

# Switch to the new user
echo -e "${YELLOW}Switching to user '$USERNAME'...${NC}"
echo "Type 'exit' to return to root."

exec su - "$USERNAME"
