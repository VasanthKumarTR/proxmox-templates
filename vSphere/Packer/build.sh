#!/bin/bash
###############################################################################
# PACKER BUILD SCRIPT
###############################################################################
# This script automates the process of building an Ubuntu 24.04 template VM
# in vSphere using Packer. It handles all the necessary setup and validation
# before starting the build process.
###############################################################################

# Navigate to the directory containing this script
# This ensures the script runs correctly regardless of where it was called from
cd "$(dirname "$0")"

###############################################################################
# DEPENDENCY VALIDATION
###############################################################################

# Check if Packer is installed
# If not, provide instructions for installation and exit
if ! command -v packer &> /dev/null; then
    echo "Packer is not installed. Please install it from https://www.packer.io/downloads"
    exit 1
fi

###############################################################################
# CONFIGURATION VALIDATION
###############################################################################

# Check if secrets file exists
# The secrets file contains sensitive information like vSphere credentials
if [ ! -f "secrets.pkrvars.hcl" ]; then
    echo "Creating example secrets file..."
    cp example.pkrvars.hcl secrets.pkrvars.hcl
    echo "Please edit secrets.pkrvars.hcl with your actual vSphere credentials before running this script again."
    exit 1
fi

###############################################################################
# PACKER INITIALIZATION & BUILD
###############################################################################

# Initialize Packer plugins
# This downloads and initializes any required Packer plugins
echo "Initializing Packer plugins..."
packer init ubuntu-24-04.pkr.hcl

# Run Packer build with variable files
# This starts the actual build process with detailed logging
echo "Starting Packer build..."
PACKER_LOG=1 packer build -force -on-error=ask \
  -var-file=secrets.pkrvars.hcl \
  -var-file=variables.pkrvars.hcl \
  ubuntu-24-04.pkr.hcl

echo "Build process completed!" 