# Proxmox Ubuntu 24.04 VM Terraform Configuration

This Terraform configuration allows you to easily provision Ubuntu 24.04 virtual machines on a Proxmox server using the BPG Proxmox provider.

## Prerequisites

* Terraform installed (version 1.5.0+)
* Access to a Proxmox server (version 8.0+) with an API token
* Ubuntu 24.04 server image available in Proxmox

## Usage

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Edit `terraform.tfvars` with your specific configuration
4. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration Options

Edit `terraform.tfvars` to customize your VM:

| Variable | Description | Default |
|----------|-------------|---------|
| proxmox_api_url | URL of your Proxmox API | None (Required) |
| proxmox_api_token_id | Proxmox API token ID | None (Required) |
| proxmox_api_token_secret | Proxmox API token secret | None (Required) |
| vm_name | Name of the VM | "ubuntu-vm" |
| target_node | Proxmox node to deploy on | None (Required) |
| vm_cores | Number of CPU cores | 2 |
| vm_memory | RAM in MB | 2048 |
| disk_size | Disk size in GB | "20" |
| disk_storage | Storage pool | "local-lvm" |
| network_bridge | Network bridge | "vmbr0" |
| ssh_public_keys | SSH key for access | None (Required) |

## Output

After successful deployment, the VM's IP address will be displayed as an output.

## Notes

* This configuration uses the BPG Proxmox provider (bpg/proxmox)
* The VM will receive an IP via DHCP by default
* A serial device is added to ensure compatibility with modern Ubuntu versions
* Make sure your Proxmox user has sufficient permissions (see below)

