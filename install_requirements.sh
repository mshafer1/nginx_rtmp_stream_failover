#!/bin/bash

# bail if we hit an error
set -euo pipefail
trap 'echo "Error occurred on line $LINENO"; exit 1' ERR

# update indexes
apt-get update

# install Python3 and pip3
apt-get install -y python3 python3-pip pipx

# Use pip to install ansible
pipx install ansible --include-deps

pipx ensurepath

echo "Reload shell variables by relaunching or by running"
echo "source ~/.bashrc"
