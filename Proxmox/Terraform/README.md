# Proxmox Ubuntu 24.04 VM Terraform Configuration

This Terraform configuration allows you to easily provision Ubuntu 24.04 virtual machines on a Proxmox server using the BPG Proxmox provider.

## Versions Used

This configuration has been tested with the following specific versions:

- **Proxmox Virtual Environment**: 8.4.0
- **Terraform**: v1.5.7
- **Ubuntu**: 24.04 LTS (using ubuntu-24.04.2-live-server-amd64.iso)

## Prerequisites

* Terraform installed (version 1.5.7+)
* Access to a Proxmox server (version 8.4.0+) with an API token
* Ubuntu 24.04 server template available in Proxmox

## Usage

1. Clone this repository
2. Create a `terraform.tfvars` file for general configuration using the example below
3. Copy `secrets.tfvars.example` to `secrets.tfvars` for sensitive configuration
4. Edit both files with your specific configuration
5. Run the deployment script:

```bash
./build.sh
```

Or run the commands manually:

```bash
terraform init
terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"
terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"
```

## Configuration Files

This project uses two separate configuration files to improve security:

- **terraform.tfvars**: Contains non-sensitive configuration (VM specs, networking, etc.)
- **secrets.tfvars**: Contains sensitive information (API tokens, passwords)

The `secrets.tfvars` file is included in `.gitignore` to prevent accidental commits of sensitive information.

### Example terraform.tfvars

```hcl
# Proxmox API connection details
proxmox_api_url = "https://proxmox.example.com:8006"

# VM settings
vm_name     = "ubuntu-24-04-vm"
target_node = "pve"  # Replace with your Proxmox node name

# VM resources
vm_cores  = 2
vm_memory = 4096  # 4GB RAM

# Storage settings
disk_size    = "40"
disk_storage = "local-lvm"

# Network settings
network_bridge = "vmbr0"

# SSH public keys for cloud-init
ssh_public_keys = "ssh-rsa AAAAB3Nz...your-ssh-public-key"
```

### Example secrets.tfvars

See the `secrets.tfvars.example` file in the repository.

## Configuration Options

The following variables are available across both configuration files:

| Variable | Description | Default | File |
|----------|-------------|---------|------|
| proxmox_api_url | URL of your Proxmox API | None (Required) | terraform.tfvars |
| proxmox_api_token_id | Proxmox API token ID | None (Required) | secrets.tfvars |
| proxmox_api_token_secret | Proxmox API token secret | None (Required) | secrets.tfvars |
| vm_name | Name of the VM | "ubuntu-vm" | terraform.tfvars |
| target_node | Proxmox node to deploy on | None (Required) | terraform.tfvars |
| vm_cores | Number of CPU cores | 2 | terraform.tfvars |
| vm_memory | RAM in MB | 2048 | terraform.tfvars |
| disk_size | Disk size in GB | "20" | terraform.tfvars |
| disk_storage | Storage pool | "local-lvm" | terraform.tfvars |
| network_bridge | Network bridge | "vmbr0" | terraform.tfvars |
| ssh_public_keys | SSH key for access | None (Required) | terraform.tfvars |
| vm_password | Password for Ubuntu user | None (Optional) | secrets.tfvars |

## Output

After successful deployment, the VM's IP address will be displayed as an output.

## Notes

* This configuration uses the BPG Proxmox provider (bpg/proxmox)
* The VM will receive an IP via DHCP by default
* A serial device is added to ensure compatibility with modern Ubuntu versions
* Make sure your Proxmox user has sufficient permissions
* Always keep your `secrets.tfvars` file secure and never commit it to version control

