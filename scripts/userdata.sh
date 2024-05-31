#!/bin/bash
echo "User-data script running..."

# Example command to update and install a package
yum update -y
yum install -y git 
yum install -y docker 
yum install -y docker-compose
yum install -y python3.11
yum install -y java
yum install -y maven
# Validate installations
validate_install() {
  if ! command -v $1 &> /dev/null
  then
    echo "$1 could not be installed"
    exit 1
  else
    echo "$1 installed successfully"
  fi
}

validate_install git
validate_install docker
validate_install docker-compose
