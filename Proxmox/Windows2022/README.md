# Windows Server 2022 VM Automation for Proxmox

This directory contains infrastructure-as-code configurations for automatically building Windows Server 2022 VM templates and deploying virtual machines on Proxmox using Packer and Terraform.

## Repository Structure

- [`Packer/`](./Packer) - Template building with Packer
- [`Terraform/`](./Terraform) - VM deployment with Terraform

## Features

- **Windows Server 2022** template creation and deployment
- **UEFI/EFI boot** with TPM 2.0 support for enhanced security
- **VirtIO drivers** pre-installed for optimal performance
- **Automated Windows installation** using unattend.xml
- **Cloud-init integration** for Windows configuration
- **Pre-installed software** (Chrome, Firefox, 7-Zip, Git, etc.)
- **IIS and Container features** enabled
- **WinRM and RDP** configured for remote management
- **Multi-VM deployment** capabilities
- **Static IP configuration** support

## Prerequisites

### Common Requirements

- [Packer](https://www.packer.io/downloads) v1.12.0+
- [Terraform](https://www.terraform.io/downloads) v1.5.7+
- Proxmox VE 8.4.0+
- Administrator credentials for Proxmox

### Required ISOs

You must upload these ISOs to your Proxmox storage before building:

1. **Windows Server 2022 ISO**: `en-us_windows_server_2022_updated_jan_2024_x64_dvd_2b7a0c9f.iso`
   - Download from Microsoft Volume Licensing or Visual Studio Subscriptions

2. **VirtIO Drivers ISO**: `virtio-win-0.1.248.iso`
   - Download from: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/

## Quick Start

### 1. Build Template with Packer

```bash
cd Packer
cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
# Edit secrets.pkrvars.hcl with your Proxmox credentials
./build.sh
```

**Note**: The template build process takes 2-4 hours.

### 2. Deploy VMs with Terraform

```bash
cd ../Terraform
cp secrets.auto.tfvars.example secrets.auto.tfvars
# Edit terraform.tfvars and secrets.auto.tfvars with your configuration
./build.sh
```

## Template Specifications

The Packer template creates a VM with:

- **VM ID**: 9100
- **CPU**: 4 cores
- **RAM**: 4 GB
- **Disk**: 60 GB (raw format)
- **Boot**: UEFI with TPM 2.0
- **Network**: VirtIO adapter
- **Drivers**: VirtIO drivers for optimal performance

## Default Credentials

- **Username**: Administrator
- **Password**: P@ssw0rd123! (change in production!)

## Network Configuration

Default network settings:
- **Bridge**: vmbr0
- **Gateway**: 192.168.1.1
- **DNS**: 8.8.8.8, 8.8.4.4
- **Domain**: home

## Pre-installed Software

The template includes:

- **Web Browsers**: Google Chrome, Mozilla Firefox
- **Utilities**: 7-Zip, Notepad++, Git
- **Windows Features**: IIS Web Server, Windows Containers
- **Management**: QEMU Guest Agent, PowerShell 5.1+

## Security Features

- Windows Firewall properly configured
- Remote Desktop enabled with firewall rules
- PowerShell remoting enabled
- TPM 2.0 for hardware security
- UEFI Secure Boot support

## Customization

### Packer Customization

Modify these files to customize the template:

- `answer_files/autounattend.xml`: Windows installation settings
- `scripts/bootstrap.ps1`: Initial system configuration
- `scripts/setup-winrm.ps1`: WinRM configuration
- `scripts/install-updates.ps1`: Windows Update process

### Terraform Customization

Modify these files to customize VM deployment:

- `terraform.tfvars`: VM specifications and network settings
- `cloud-init.yml.tpl`: Cloud-init configuration template
- `variables.tf`: Variable definitions

## Multi-VM Deployment

The Terraform configuration supports deploying multiple VMs with different specifications:

```hcl
vms = {
  "win2022-dc" = {
    ip_address = "192.168.1.98/24"
    cores      = 4
    memory     = 8192
    disk_size  = "100"
  }
  "win2022-app" = {
    ip_address = "192.168.1.99/24"
    cores      = 4
    memory     = 4096
    disk_size  = "80"
  }
}
```

## Troubleshooting

### Packer Issues

1. **Long build times**: Normal for Windows templates (2-4 hours)
2. **VirtIO driver errors**: Verify ISO path and upload
3. **WinRM timeouts**: Check firewall and service configuration
4. **Sysprep failures**: Review Windows event logs

### Terraform Issues

1. **Template not found**: Ensure Packer build completed successfully
2. **Network configuration**: Verify bridge and IP settings
3. **Boot problems**: Check UEFI/TPM configuration
4. **Cloud-init failures**: Review Windows Event Viewer logs

## Production Considerations

### Security

- Change default Administrator password
- Implement Windows security baselines
- Configure Windows Update policies
- Enable Windows Defender
- Consider domain joining

### Performance

- Allocate appropriate CPU and memory based on workload
- Use SSD storage for better performance
- Enable VirtIO drivers for all devices
- Configure appropriate VM priorities

### Management

- Implement backup strategies
- Configure monitoring solutions
- Use configuration management tools (DSC, Ansible)
- Plan for patch management

## Integration Examples

### Active Directory Domain Controller

```hcl
# Example for domain controller VM
"win2022-dc" = {
  ip_address = "192.168.1.10/24"
  cores      = 4
  memory     = 8192
  disk_size  = "120"
}
```

### Application Server

```hcl
# Example for application server
"win2022-app" = {
  ip_address = "192.168.1.20/24"
  cores      = 8
  memory     = 16384
  disk_size  = "200"
}
```

## Documentation

- [Packer Documentation](./Packer/README.md)
- [Terraform Documentation](./Terraform/README.md)

## Support

For issues and questions:

1. Check the troubleshooting sections in component READMEs
2. Review Proxmox and Windows logs
3. Verify prerequisites and configuration
4. Test with minimal configurations first

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.

## Contributing

Contributions are welcome! Please:

1. Test your changes thoroughly
2. Update documentation as needed
3. Follow existing code style and structure
4. Provide clear commit messages
