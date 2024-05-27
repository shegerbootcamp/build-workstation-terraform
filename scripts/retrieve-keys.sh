#!/bin/bash

# Check if username is provided as input
if [ -z "$1" ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USERNAME=$1

# Directory to store keys
KEY_DIR="aws-access-keys"

# Remove existing keys if they exist
if [ -f "$KEY_DIR/${USERNAME}-private.pem" ]; then
  rm "$KEY_DIR/${USERNAME}-private.pem"
fi

if [ -f "$KEY_DIR/${USERNAME}-pub.pem" ]; then
  rm "$KEY_DIR/${USERNAME}-pub.pem"
fi

# Run AWS SSM command to get the private key and save it
aws ssm get-parameter --name "/ec2/key-pair/${USERNAME}/private-rsa-key-pem" --output text --query "Parameter.Value" > "$KEY_DIR/${USERNAME}-private.pem"

# Check if the command was successful
if [ $? -ne 0 ]; then
  echo "Failed to retrieve the private key. Please check the username and try again."
  exit 1
fi

# Run AWS SSM command to get the public key and save it
aws ssm get-parameter --name "/ec2/key-pair/${USERNAME}/public-rsa-key-openssh" --output text --query "Parameter.Value" > "$KEY_DIR/${USERNAME}-pub.pem"

# Check if the command was successful
if [ $? -ne 0 ]; then
  echo "Failed to retrieve the public key. Please check the username and try again."
  exit 1
fi

echo "Keys successfully retrieved and saved to $KEY_DIR directory"
