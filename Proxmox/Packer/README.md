# Ubuntu 24.04 Packer Template for Proxmox

This directory contains Packer configuration to build an Ubuntu 24.04 template VM in Proxmox.

## Prerequisites

1. [Packer](https://www.packer.io/downloads) installed on your machine (v1.12.0 or later recommended)
2. Access to a Proxmox server
3. Ubuntu 24.04 ISO image already uploaded to Proxmox (in local:iso storage)

## Configuration

Edit the `variables.pkrvars.hcl` file to match your environment:

- `proxmox_url`: URL to your Proxmox API
- `proxmox_username`: Your Proxmox username (usually root@pam)
- `proxmox_node`: Your Proxmox node name
- `vm_id`: The VM ID to use for the template
- `iso_file`: Path to the Ubuntu ISO in your Proxmox storage

## Secrets Configuration

For security, sensitive information like passwords is stored in a separate file:

1. Copy the example secrets file:
   ```
   cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
   ```

2. Edit `secrets.pkrvars.hcl` with your actual Proxmox password and SSH password.

The `secrets.pkrvars.hcl` file is included in `.gitignore` to prevent accidental commits of sensitive information.

## Building the Template

1. Make the build script executable:
   ```
   chmod +x build.sh
   ```

2. Run the build script:
   ```
   ./build.sh
   ```

The script will use your credentials from the secrets file and start the build process.

## How It Works

1. Packer creates a VM in Proxmox using the specified ISO
2. It performs an automated installation using cloud-init configuration provided via CD-ROM (rather than HTTP)
3. After installation, it runs post-installation scripts to update the system and install necessary packages
4. Finally, it converts the VM to a template

## Cloud-Init Configuration Approach

This template uses a CD-ROM-based approach for cloud-init configuration instead of the HTTP method:

- The configuration files (meta-data and user-data) are packaged into a virtual CD-ROM
- This CD is attached to the VM during boot
- Ubuntu's cloud-init detects this CD and applies the configuration
- This approach is more reliable than HTTP, especially in networking-restricted environments

The relevant files are:
- `http/user-data`: Contains the cloud-init configuration for automated installation
- `http/meta-data`: Contains instance metadata for cloud-init

## Customization

- `http/user-data`: Contains the cloud-init configuration for automated installation
- `http/meta-data`: Contains instance metadata for cloud-init
- `ubuntu-2404.pkr.hcl`: Main Packer configuration file
- `variables.pkrvars.hcl`: Variables file for customization
- `secrets.pkrvars.hcl`: Sensitive credentials (not committed to version control)

## Using the Template in Terraform

After the template is created, you can use it with the Proxmox provider for Terraform:

```hcl
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "my-ubuntu-vm"
  description = "Ubuntu VM from template"
  node_name   = "proxmox"
  
  clone {
    vm_id = 9000  # The template VM ID
    full  = true
  }
  
  # Add other configuration as needed
}
```

## Troubleshooting

If you encounter issues with the build process:

1. Check that your Packer version is 1.12.0 or later
2. Verify your Proxmox credentials and permissions
3. Ensure the Ubuntu ISO exists in the specified Proxmox storage location
4. Review the cloud-init files for any syntax errors

The CD-ROM-based approach should work reliably in WSL2 environments without any special port forwarding or network configuration. 