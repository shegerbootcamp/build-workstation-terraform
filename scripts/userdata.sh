#!/bin/bash
echo "User-data script running..."

# Example command to update and install a package
yum update -y
yum install git -y
yum install docker -y
yum install docker-compose -y
yum install python3.11 -y
yum install java -y
yum install maven -y

python3.11 -m pip install watchmaker

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

echo "User-data script completed."