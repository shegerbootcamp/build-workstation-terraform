#!/bin/bash

# Function to set up the SSH user
ssh_user_setup() {
  # Add the new user
  useradd -m -s /bin/bash ${USERNAME}

  # Add the user to specified groups
  usermod -aG wheel,adm,maintuser ${USERNAME}

  # Grant sudo privileges
  echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${USERNAME}

  # Create .ssh directory for the new user
  mkdir -p /home/${USERNAME}/.ssh

  # Add the public key to the authorized_keys file
  echo "${PUBLIC_KEY_CONTENT}" > /home/${USERNAME}/.ssh/authorized_keys

  # Set the correct permissions
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh
  chmod 700 /home/${USERNAME}/.ssh
  chmod 600 /home/${USERNAME}/.ssh/authorized_keys
}

# Function to install and run Watchmaker
watchmaker_run() {
  echo "Installing and running watchmaker"

  PYPI_URL=https://pypi.org/simple

  # Setup terminal support for UTF-8
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8

  # Install pip
  python3 -m ensurepip

  # Install setup dependencies
  python3 -m pip install --index-url="$PYPI_URL" --upgrade pip setuptools

  # Install Watchmaker
  python3 -m pip install --index-url="$PYPI_URL" --upgrade watchmaker

  # Run Watchmaker
  watchmaker --log-level debug --log-dir=/var/log/watchmaker

  echo "Watchmaker run completed"
}

# Execute functions
ssh_user_setup
watchmaker_run