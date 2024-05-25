#!/bin/bash
set -e

USERNAME="${USERNAME}"
PUBLIC_KEY_PATH="${PUBLIC_KEY_PATH}"

# Create a new user if it does not exist
if id -u "$USERNAME" >/dev/null 2>&1; then
    echo "User $USERNAME already exists"
else
    echo "Creating user $USERNAME..."
    useradd -m -s /bin/bash "$USERNAME"
fi

# Add the user to the wheel group for sudo privileges
usermod -aG wheel "$USERNAME"

# Create .ssh directory and authorized_keys file with correct permissions
USER_HOME=$(eval echo ~"$USERNAME")
SSH_DIR="$USER_HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"

# Read the public key from the file and write it to the authorized_keys file
if [ -f "$PUBLIC_KEY_PATH" ]; then
    cat "$PUBLIC_KEY_PATH" > "$SSH_DIR/authorized_keys"
else
    echo "Public key file not found: $PUBLIC_KEY_PATH" >&2
    exit 1
fi

# Set the appropriate permissions
chown -R "$USERNAME":"$USERNAME" "$SSH_DIR"
chmod 600 "$SSH_DIR/authorized_keys"
