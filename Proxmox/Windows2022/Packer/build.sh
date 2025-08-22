#!/bin/bash
# =====================================================================================
# PACKER BUILD SCRIPT FOR WINDOWS SERVER 2022 PROXMOX TEMPLATE
# =====================================================================================
# This script automates the Packer build process for creating a Windows Server 2022 
# template on Proxmox VE. It handles initialization, variable loading, and build execution.

# Navigate to the directory containing this script
# This ensures the script works regardless of where it's called from
cd "$(dirname "$0")"

# Check if Packer is installed
# Verifies that the 'packer' command is available in the system PATH
if ! command -v packer &> /dev/null; then
    echo "Packer is not installed. Please install it from https://www.packer.io/downloads"
    exit 1
fi

# Check if secrets file exists
# The secrets file contains sensitive information like API tokens and passwords
if [ ! -f "secrets.pkrvars.hcl" ]; then
    echo "Creating example secrets file..."
    cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
    echo "Please edit secrets.pkrvars.hcl with your actual credentials before running this script again."
    exit 1
fi

# Validate ISO files existence
echo "Checking ISO file requirements..."
echo "Please ensure you have uploaded the following ISOs to your Proxmox storage:"
echo "1. Windows Server 2022 ISO (en-us_windows_server_2022_updated_jan_2024_x64_dvd_2b7a0c9f.iso)"
echo "2. VirtIO drivers ISO (virtio-win-0.1.248.iso)"
echo ""
echo "You can download VirtIO drivers from: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/"
echo ""

# Initialize Packer plugins
# This downloads and installs the required Packer plugins defined in the .pkr.hcl file
echo "Initializing Packer plugins..."
packer init windows-2022.pkr.hcl

# Run Packer build with both variable files
# -force: Overwrites any existing output artifacts
# -on-error=ask: Prompts for user input if an error occurs during the build
echo "Starting Packer build for Windows Server 2022..."
echo "Note: This build process typically takes 2-4 hours depending on your hardware and network speed."
packer build -force -on-error=ask \
  -var-file=variables.pkrvars.hcl \
  -var-file=secrets.pkrvars.hcl \
  windows-2022.pkr.hcl

echo "Build process completed!"
