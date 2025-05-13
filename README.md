# Ubuntu 24.04 VMs for Proxmox and vSphere

This repository contains Packer templates and Terraform configurations to create Ubuntu 24.04 virtual machines in both Proxmox and vSphere environments.

## Overview

This project is organized into two main sections:

- **Proxmox**: Templates and configurations for Proxmox VE
- **vSphere**: Templates and configurations for VMware vSphere

Each section contains both Packer templates for creating VM templates and Terraform configurations for deploying VMs from those templates.

## Requirements

- [Packer](https://developer.hashicorp.com/packer/downloads) (>= 1.9.0)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.7.0)
- Access to either a Proxmox server or vSphere environment
- Ubuntu 24.04 ISO (downloaded automatically by Packer)

## Workflow

1. Use Packer to create VM templates in your virtualization platform
2. Use Terraform to deploy VMs from those templates

## Proxmox

### Creating VM Templates with Packer

The Packer configuration for Proxmox will:

1. Download the Ubuntu 24.04 ISO if not present
2. Create a new VM in Proxmox
3. Install Ubuntu with preseed configuration
4. Install common packages and perform system hardening
5. Convert the VM to a template

To build the template:

```bash
cd Proxmox/Packer
cp example.pkrvars.hcl local.pkrvars.hcl
# Edit local.pkrvars.hcl with your Proxmox details
packer build -var-file=local.pkrvars.hcl .
```

### Deploying VMs with Terraform

After creating the template with Packer, you can use Terraform to deploy VMs:

```bash
cd Proxmox/Terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
terraform init
terraform plan
terraform apply
```

## vSphere

### Creating VM Templates with Packer

The Packer configuration for vSphere will:

1. Connect to your vSphere environment
2. Upload the Ubuntu 24.04 ISO if needed
3. Create a new VM
4. Install Ubuntu with automated configuration
5. Install VM tools and perform system optimization
6. Convert the VM to a template

To build the template:

```bash
cd vSphere/Packer
cp example.pkrvars.hcl local.pkrvars.hcl
# Edit local.pkrvars.hcl with your vSphere details
packer build -var-file=local.pkrvars.hcl .
```

### Deploying VMs with Terraform

After creating the template with Packer, you can use Terraform to deploy VMs:

```bash
cd vSphere/Terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
terraform init
terraform plan
terraform apply
```

## Customization

Both the Packer templates and Terraform configurations are designed to be customizable:

- Modify the Packer HTTP directory files to change installation parameters
- Adjust VM specifications in both Packer and Terraform configurations
- Add or modify provisioning scripts to install additional software
- Customize network configurations to match your environment

## License

This project is licensed under the MIT License - see the LICENSE file for details.