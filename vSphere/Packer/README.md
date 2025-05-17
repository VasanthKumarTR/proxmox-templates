# vSphere Ubuntu 24.04 Packer Template

This directory contains Packer configuration to build an Ubuntu 24.04 template VM in vSphere.

## Versions Used

This template has been tested with the following specific versions:

- **vSphere vCenter**: 7.0.3.01800 (Build number: 22837322)
- **ESXi host**: v6.7
- **Packer**: v1.12.0
- **Ubuntu**: 24.04 LTS (using ubuntu-24.04.2-live-server-amd64.iso)

## Prerequisites

* [Packer](https://www.packer.io/downloads) installed on your machine (v1.12.0 or later)
* Access to a vSphere environment with vCenter 7.0.3+ and ESXi 6.7+
* Network connectivity to download the Ubuntu 24.04.2 ISO (or pre-uploaded ISO to datastore)

## Features

* Creates a fully-automated Ubuntu 24.04 template VM in vSphere
* Installs Docker 27.5.1 with docker-compose
* Configures cloud-init for VM customization
* Optimized for template conversion with proper cleanup
* CD-ROM based cloud-init for reliable deployment
* VMware tools installed and configured

## Configuration

Edit the `variables.pkrvars.hcl` file to match your environment:

- `vm_name`: Name of the VM template
- `vm_cpu_sockets` and `vm_cpu_cores`: CPU configuration
- `vm_mem_size`: Memory in MB
- `vm_disk_size`: Disk size in MB
- `thin_provision`: Whether to thin provision the disk

## Secrets Configuration

For security, sensitive information like passwords is stored in a separate file:

1. Copy the example secrets file:
   ```
   cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
   ```

2. Edit `secrets.pkrvars.hcl` with your actual vSphere credentials:
   - `vcenter_username`: vCenter username
   - `vcenter_password`: vCenter password
   - `vcenter_server`: vCenter server address
   - Other vSphere environment settings (datacenter, datastore, etc.)

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

1. Packer creates a VM in vSphere using the specified ISO
2. It performs an automated installation using cloud-init configuration provided via CD-ROM
3. After installation, it runs post-installation scripts to:
   - Configure the system
   - Install Docker 27.5.1
   - Perform cleanup operations
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

## Troubleshooting

If you encounter issues with the build process:

1. Check that you're using Packer v1.12.0 or later
2. Verify your vSphere credentials and permissions
3. Ensure the path to ISO is correct or it can be downloaded from the specified URL
4. Review the cloud-init files for any syntax errors
5. Check if your vSphere environment supports the VM hardware version specified
6. For networking issues, verify that your VM network settings match your environment

### ISO Checksum Issues

If you get a checksum error like this:
```
Checksums did not match for *.iso
Expected: [checksum1]
Got: [checksum2]
```

This means the ISO file has been updated on the Ubuntu servers. To fix this:

1. Check the current checksum with:
   ```bash
   curl -s https://releases.ubuntu.com/24.04/SHA256SUMS | grep live-server-amd64.iso
   ```

2. Update both files with the new checksum:
   - `ubuntu-24-04.pkr.hcl`: Update the `iso_checksum` variable default value
   - `variables.pkrvars.hcl`: Update the `iso_checksum` value

## Using the Template with Terraform

After creating the template, you can use it with the Terraform configuration in the `../Terraform` directory. See that directory's README for details on deploying VMs from this template. 