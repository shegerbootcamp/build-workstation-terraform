#!/bin/bash

# Variables from Terraform
USERNAME="${USERNAME}"
PUBLIC_KEY_CONTENT="${PUBLIC_KEY_CONTENT}"

# Create the user with a specified gecos field
sudo useradd -m -s /bin/bash -c "User D. Two" $USERNAME

# Grant sudo privileges
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USERNAME

# Add the user to specified groups
sudo usermod -aG wheel,adm,systemd-journal,maintuser $USERNAME

# Enable password authentication for SSH
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Create .ssh directory and add the public key
sudo mkdir -p /home/$USERNAME/.ssh
echo $PUBLIC_KEY_CONTENT | sudo tee /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys

echo "User setup completed successfully!"