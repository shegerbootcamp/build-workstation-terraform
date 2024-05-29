#!/bin/bash
set -e

# Any other setup tasks you want to perform
echo "User-data script running..."

# Example command to update and install a package
yum update -y
yum install -y git
