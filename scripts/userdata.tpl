#!/bin/bash
echo "User-data script running..."

# Example command to update and install a package
yum install git -y
yum install docker -y
yum install docker-compose -y
yum install python3.11 -y
yum install java -y
yum install maven -y

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
validate_install python3.11
validate_install java
validate_install mvn
