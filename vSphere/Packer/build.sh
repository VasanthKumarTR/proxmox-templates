#!/bin/bash

# Navigate to the directory containing this script
cd "$(dirname "$0")"

# Check if Packer is installed
if ! command -v packer &> /dev/null; then
    echo "Packer is not installed. Please install it from https://www.packer.io/downloads"
    exit 1
fi

# Check if secrets file exists
if [ ! -f "secrets.pkrvars.hcl" ]; then
    echo "Creating example secrets file..."
    cp example.pkrvars.hcl secrets.pkrvars.hcl
    echo "Please edit secrets.pkrvars.hcl with your actual vSphere credentials before running this script again."
    exit 1
fi

# Initialize Packer plugins
echo "Initializing Packer plugins..."
packer init ubuntu-24-04.pkr.hcl

# Run Packer build with variable files
echo "Starting Packer build..."
PACKER_LOG=1 packer build -force -on-error=ask \
  -var-file=secrets.pkrvars.hcl \
  -var-file=variables.pkrvars.hcl \
  ubuntu-24-04.pkr.hcl

echo "Build process completed!" 