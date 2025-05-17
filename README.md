# Ubuntu 24.04 VM Automation for vSphere and Proxmox

This repository contains infrastructure-as-code configurations for automatically building Ubuntu 24.04 VM templates and deploying virtual machines using:

- **vSphere**: VMware's enterprise virtualization platform
- **Proxmox**: Open-source virtualization platform

The repository provides a complete workflow for both platforms, from template creation to VM deployment, using Packer and Terraform.

## Versions Used

This repository has been tested with the following specific versions:

- **Proxmox Virtual Environment**: 8.4.0
- **vSphere vCenter**: 7.0.3.01800 (Build number: 22837322)
- **ESXi host**: v6.7
- **Packer**: v1.12.0
- **Terraform**: v1.5.7
- **Ubuntu**: 24.04 LTS (using ubuntu-24.04.2-live-server-amd64.iso)

## Repository Structure

- [`vSphere/`](./vSphere) - VMware vSphere configurations
  - [`Packer/`](./vSphere/Packer) - Template building with Packer
  - [`Terraform/`](./vSphere/Terraform) - VM deployment with Terraform

- [`Proxmox/`](./Proxmox) - Proxmox VE configurations
  - [`Packer/`](./Proxmox/Packer) - Template building with Packer
  - [`Terraform/`](./Proxmox/Terraform) - VM deployment with Terraform

## Features

### Common Features

- **Ubuntu 24.04 LTS** template creation and deployment
- **Cloud-init integration** for first-boot customization
- **Docker pre-installation** (version 27.5.1)
- **CD-ROM-based cloud-init** for reliable deployment
- **SSH key injection** for secure access
- **Multi-VM deployment** capabilities
- **Resource customization** (CPU, memory, disk)

### vSphere-specific Features

- VMware tools integration
- vSphere-optimized template
- Support for vCenter deployment
- VM folder organization

### Proxmox-specific Features

- Compatibility with Proxmox VE 8.0+
- Uses BPG Proxmox Terraform provider
- Serial device configuration for modern Ubuntu compatibility

## Prerequisites

### Common Requirements

- [Packer](https://www.packer.io/downloads) v1.12.0+
- [Terraform](https://www.terraform.io/downloads) v1.5.7+
- SSH keypair for VM access
- Ubuntu 24.04.2 ISO (ubuntu-24.04.2-live-server-amd64.iso)

### vSphere Requirements

- vSphere environment with vCenter 7.0.3+
- ESXi host v6.7+
- Administrator credentials
- Network with internet access for ISO download (or pre-uploaded ISO)

### Proxmox Requirements

- Proxmox VE 8.4.0+
- API token with appropriate permissions
- Ubuntu 24.04 ISO already uploaded to Proxmox storage

## Quick Start

### vSphere Workflow

1. **Build Template:**
   ```bash
   cd vSphere/Packer
   cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
   # Edit secrets.pkrvars.hcl with your vSphere credentials
   ./build.sh
   ```

2. **Deploy VMs:**
   ```bash
   cd ../Terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your configuration
   ./build.sh
   ```

### Proxmox Workflow

1. **Build Template:**
   ```bash
   cd Proxmox/Packer
   cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
   # Edit secrets.pkrvars.hcl with your Proxmox credentials
   ./build.sh
   ```

2. **Deploy VMs:**
   ```bash
   cd ../Terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your configuration
   terraform init
   terraform plan
   terraform apply
   ```

## Documentation

Each component has detailed documentation:

- [vSphere Packer Documentation](./vSphere/Packer/README.md)
- [vSphere Terraform Documentation](./vSphere/Terraform/README.md)
- [Proxmox Packer Documentation](./Proxmox/Packer/README.md)
- [Proxmox Terraform Documentation](./Proxmox/Terraform/README.md)

## Security Notes

- Default username is "ubuntu"
- Default password is "ubuntu" - change it in production!
- SSH keys are used for secure authentication
- API tokens and credentials should be kept secret (never commit to repositories)

## Troubleshooting

Common issues and solutions are documented in each component's README file. General troubleshooting tips:

1. Check your Packer and Terraform versions
2. Verify credentials and permissions
3. Ensure network connectivity to download ISO or connect to VMs
4. Review cloud-init configurations for syntax errors
5. Check logs for error messages

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
