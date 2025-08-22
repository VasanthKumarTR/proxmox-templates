# Proxmox Windows Server 2022 VM Terraform Configuration

This Terraform configuration allows you to easily provision Windows Server 2022 virtual machines on a Proxmox server using the BPG Proxmox provider.

## Versions Used

This configuration has been tested with the following specific versions:

- **Proxmox Virtual Environment**: 8.4.0+
- **Terraform**: v1.5.7+
- **Windows Server 2022**: Updated January 2024 edition

## Prerequisites

* Terraform installed (version 1.5.7+)
* Access to a Proxmox server (version 8.4.0+) with an API token
* Windows Server 2022 template available in Proxmox (created with the Packer template)

## Usage

1. Build the Windows Server 2022 template using Packer first (see ../Packer directory)
2. Create a `terraform.tfvars` file for general configuration using the example below
3. Copy `secrets.auto.tfvars.example` to `secrets.auto.tfvars` for sensitive configuration
4. Edit both files with your specific configuration
5. Run the deployment script:

```bash
./build.sh
```

Or run the commands manually:

```bash
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="secrets.auto.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="secrets.auto.tfvars"
```

## Configuration Files

This project uses two separate configuration files to improve security:

- **terraform.tfvars**: Contains non-sensitive configuration (VM specs, networking, etc.)
- **secrets.auto.tfvars**: Contains sensitive information (API tokens, passwords)

The `secrets.auto.tfvars` file is included in `.gitignore` to prevent accidental commits of sensitive information.

### Example terraform.tfvars

```hcl
# Proxmox API connection details
proxmox_api_url = "https://proxmox.example.com:8006"

# VM settings
target_node = "pve"  # Replace with your Proxmox node name

# Storage settings
disk_storage = "local-lvm"

# Network settings
network_bridge = "vmbr0"
gateway        = "192.168.1.1"
dns_servers    = ["8.8.8.8", "8.8.4.4"]
dns_domain     = "home"

# VM configurations
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

### Example secrets.auto.tfvars

See the `secrets.auto.tfvars.example` file in the repository.

## Configuration Options

The following variables are available across both configuration files:

| Variable | Description | Default | File |
|----------|-------------|---------|------|
| proxmox_api_url | URL of your Proxmox API | None (Required) | terraform.tfvars |
| proxmox_api_token_id | Proxmox API token ID | None (Required) | secrets.auto.tfvars |
| proxmox_api_token_secret | Proxmox API token secret | None (Required) | secrets.auto.tfvars |
| target_node | Proxmox node to deploy on | None (Required) | terraform.tfvars |
| disk_storage | Storage pool | "local-lvm" | terraform.tfvars |
| network_bridge | Network bridge | "vmbr0" | terraform.tfvars |
| gateway | Network gateway | "192.168.1.1" | terraform.tfvars |
| dns_servers | DNS servers | ["8.8.8.8", "8.8.4.4"] | terraform.tfvars |
| dns_domain | DNS domain | "home" | terraform.tfvars |
| vm_password | Administrator password | "P@ssw0rd123!" | secrets.auto.tfvars |
| vms | VM configurations | See variables.tf | terraform.tfvars |

## VM Configuration

Each VM in the `vms` map supports the following configuration:

- **ip_address**: Static IP address with CIDR notation (e.g., "192.168.1.98/24")
- **cores**: Number of CPU cores
- **memory**: RAM in MB
- **disk_size**: Disk size in GB (as string)

## Windows-Specific Features

This configuration includes Windows-specific optimizations:

- **UEFI/EFI boot**: Modern boot configuration
- **TPM 2.0**: Trusted Platform Module support
- **VirtIO drivers**: High-performance drivers for Windows
- **Cloud-init**: Windows-compatible cloud-init configuration
- **Remote Desktop**: Automatically configured and enabled
- **Network configuration**: Static IP assignment via cloud-init

## Output

After successful deployment, the configuration provides:

- **vm_ip_addresses**: IP addresses of all created VMs
- **vm_connection_info**: Connection details including usernames and ports

## Connection Information

Default connection details for deployed VMs:

- **Username**: Administrator
- **Password**: As configured in secrets.auto.tfvars
- **RDP Port**: 3389
- **WinRM Port**: 5985

## Template Requirements

This Terraform configuration expects a Windows Server 2022 template with VM ID 9100. The template should be created using the Packer configuration in the `../Packer` directory.

## Network Configuration

VMs are configured with:
- Static IP addresses via cloud-init
- Custom DNS servers
- Specified network gateway
- Automatic hostname configuration

## Security Considerations

- Change default Administrator password in production
- Configure Windows Firewall rules as needed
- Enable Windows Update policies
- Consider domain joining for enterprise environments
- Implement proper backup strategies

## Troubleshooting

Common issues and solutions:

1. **Template not found**: Ensure the Windows Server 2022 template (VM ID 9100) exists
2. **Network issues**: Verify bridge configuration and IP address ranges
3. **Boot problems**: Check UEFI/EFI and TPM configuration
4. **Cloud-init failures**: Review cloud-init logs in the Windows Event Viewer
5. **Performance issues**: Ensure VirtIO drivers are properly installed

## Advanced Configuration

For advanced use cases, you can customize:

- VM hardware specifications (CPU, memory, disk)
- Network configuration (VLANs, multiple interfaces)
- Storage configuration (multiple disks, different storage pools)
- Cloud-init templates for custom software installation
- Windows features and roles configuration

## Integration with Active Directory

For domain environments, consider additional configuration:

```hcl
# Example domain configuration in cloud-init template
runcmd:
  - powershell.exe -Command "Add-Computer -DomainName 'your.domain.com' -Credential (Get-Credential) -Restart"
```

## Monitoring and Management

Recommended tools for managing deployed VMs:

- Windows Admin Center
- PowerShell DSC
- SCCM/WSUS for updates
- Azure Arc for hybrid management
- Monitoring solutions (PRTG, SolarWinds, etc.)

## License

This project follows the same MIT License as the parent repository.
