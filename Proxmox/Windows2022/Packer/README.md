# Windows Server 2022 Packer Template for Proxmox

This directory contains Packer configuration to build a Windows Server 2022 template VM in Proxmox.

## Versions Used

This template has been tested with the following specific versions:

- **Proxmox Virtual Environment**: 8.4.0+
- **Packer**: v1.12.0+
- **Windows Server 2022**: Updated January 2024 edition

## Prerequisites

1. [Packer](https://www.packer.io/downloads) installed on your machine (v1.12.0 or later)
2. Access to a Proxmox server running version 8.4.0+
3. Windows Server 2022 ISO image uploaded to Proxmox (in local:iso storage)
4. VirtIO drivers ISO uploaded to Proxmox (virtio-win-0.1.248.iso)

## Required ISOs

You need to upload these ISOs to your Proxmox storage before building:

1. **Windows Server 2022 ISO**: `en-us_windows_server_2022_updated_jan_2024_x64_dvd_2b7a0c9f.iso`
   - Download from Microsoft Volume Licensing Service Center or Visual Studio Subscriptions

2. **VirtIO Drivers ISO**: `virtio-win-0.1.248.iso`
   - Download from: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/

## Configuration

Edit the `variables.pkrvars.hcl` file to match your environment:

- `proxmox_url`: URL to your Proxmox API
- `proxmox_username`: Your Proxmox username (usually root@pam)
- `proxmox_node`: Your Proxmox node name
- `vm_id`: The VM ID to use for the template (default: 9100)
- `iso_file`: Path to the Windows Server 2022 ISO in your Proxmox storage
- `virtio_iso_file`: Path to the VirtIO drivers ISO

## Secrets Configuration

For security, sensitive information like passwords is stored in a separate file:

1. Copy the example secrets file:
   ```
   cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
   ```

2. Edit `secrets.pkrvars.hcl` with your actual Proxmox API token and desired Windows password.

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

**Note**: The Windows template build process typically takes 2-4 hours depending on your hardware and network speed.

## How It Works

1. Packer creates a VM in Proxmox using the Windows Server 2022 ISO
2. It performs an automated installation using an unattend.xml file
3. VirtIO drivers are automatically installed for optimal performance
4. Post-installation scripts configure the system:
   - Install Windows updates
   - Install common software (Chrome, Firefox, 7-Zip, etc.)
   - Enable IIS and Container features
   - Configure WinRM for remote management
5. Finally, it runs Sysprep to generalize the installation and converts the VM to a template

## Template Features

The created template includes:

- **UEFI Boot**: Modern UEFI/EFI boot configuration
- **TPM 2.0**: Trusted Platform Module for enhanced security
- **VirtIO Drivers**: High-performance drivers for disk, network, and balloon
- **QEMU Guest Agent**: For better integration with Proxmox
- **Pre-installed Software**:
  - Google Chrome
  - Mozilla Firefox
  - 7-Zip
  - Notepad++
  - Git
- **Windows Features**:
  - IIS Web Server
  - Windows Containers support
- **Security Configuration**:
  - Windows Firewall properly configured
  - Remote Desktop enabled
  - PowerShell remoting enabled

## System Requirements

The template is configured with:
- **CPU**: 4 cores
- **RAM**: 4 GB
- **Disk**: 60 GB (raw format)
- **Network**: VirtIO adapter

## Default Credentials

- **Username**: Administrator
- **Password**: P@ssw0rd123! (change this in production!)

## Using the Template in Terraform

After the template is created, you can use it with the Proxmox provider for Terraform:

```hcl
resource "proxmox_virtual_environment_vm" "windows_vm" {
  name        = "my-windows-vm"
  description = "Windows Server 2022 VM from template"
  node_name   = "proxmox"
  
  clone {
    vm_id = 9100  # The template VM ID
    full  = true
  }
  
  # Add other configuration as needed
}
```

## Troubleshooting

If you encounter issues with the build process:

1. **Build takes too long**: This is normal for Windows templates. Ensure you have good network connectivity for downloading updates.

2. **VirtIO drivers not found**: Verify the VirtIO ISO is uploaded and the path in variables.pkrvars.hcl is correct.

3. **WinRM connection issues**: Check that Windows Firewall is properly configured and WinRM service is running.

4. **Sysprep fails**: Review the Windows event logs for sysprep errors. Common issues include pending Windows updates or third-party software conflicts.

5. **Template doesn't boot**: Ensure UEFI/EFI configuration is correct in both Packer and Proxmox settings.

## Customization

You can customize the template by modifying:

- `answer_files/autounattend.xml`: Windows installation settings
- `scripts/bootstrap.ps1`: Initial system configuration
- `scripts/setup-winrm.ps1`: WinRM configuration
- `scripts/install-updates.ps1`: Windows Update process
- `windows-2022.pkr.hcl`: Packer build configuration

## Security Notes

- Change the default Administrator password in production deployments
- The template includes Windows Firewall configuration but review settings for your environment
- Consider implementing additional security hardening based on your organization's requirements
- The WinRM configuration allows unencrypted communication for the build process - this should be secured in production
