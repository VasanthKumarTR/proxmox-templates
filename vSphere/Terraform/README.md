# vSphere Ubuntu 24.04 VM Terraform Configuration

This Terraform configuration allows you to easily provision Ubuntu 24.04 virtual machines on a vSphere environment from your pre-built template.

## Versions Used

This configuration has been tested with the following specific versions:

- **vSphere vCenter**: 7.0.3.01800 (Build number: 22837322)
- **ESXi host**: v6.7
- **Terraform**: v1.5.7
- **Ubuntu**: 24.04 LTS (using ubuntu-24.04.2-live-server-amd64.iso)

## Prerequisites

* Terraform installed (version 1.5.7+)
* Access to a vSphere environment with vCenter 7.0.3+ and ESXi 6.7+
* Ubuntu 24.04 template created with the Packer configuration in the `../Packer` directory

## Features

* Deploy multiple VMs in parallel
* Customize VM resources (CPU, memory, disk)
* Cloud-init integration for first-boot customization
* SSH key injection for secure access
* Optional password override for the default user
* Post-deployment configuration via SSH

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Edit `terraform.tfvars` with your specific configuration
3. Run the deployment script:

```bash
./build.sh
```

Or run the commands manually:

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Configuration Options

Edit `terraform.tfvars` to customize your deployment:

| Variable | Description | Default |
|----------|-------------|---------|
| vsphere_user | vSphere username | None (Required) |
| vsphere_password | vSphere password | None (Required) |
| vsphere_server | vSphere server address | None (Required) |
| datacenter | vSphere datacenter name | None (Required) |
| cluster | vSphere cluster name | None (Required) |
| datastore | vSphere datastore name | None (Required) |
| network | vSphere network name | None (Required) |
| template_name | VM template name to clone from | None (Required) |
| vm_folder | VM folder to create VMs in | None (Required) |
| vm_name_prefix | Prefix for VM names | "ubuntu24" |
| domain | Domain name for VMs | "local" |
| vm_count | Number of VMs to create | 1 |
| num_cpus | Number of vCPUs for the VM | 2 |
| memory | Memory in MB for the VM | 2048 |
| disk_size | Disk size in GB (0 = use template size) | 0 |
| ssh_username | SSH username for remote access | "ubuntu" |
| ssh_private_key_path | Path to SSH private key | None (Required) |
| ssh_public_key_path | Path to SSH public key | "~/.ssh/id_rsa.pub" |
| ssh_public_key | Direct SSH public key string | "" |
| override_password | Whether to override the template's password | false |
| vm_password | Password for the VM user | "" |

## Cloud-Init Configuration

This configuration uses vSphere's cloud-init integration to customize VMs at first boot:

1. **SSH Key Injection**: Your public SSH key is automatically injected into authorized_keys
2. **Hostname Configuration**: Each VM gets a unique hostname based on the prefix and count
3. **Password Override**: Optionally override the default user password
4. **Post-deployment Tasks**: Run initial configuration commands via SSH

The cloud-init configuration templates are located in the `cloud-init/` directory:
- `meta-data.tftpl`: VM instance metadata
- `user-data.tftpl`: User configuration template

## Project Structure

- `main.tf`: Main Terraform configuration for VM deployment
- `variables.tf`: Variable definitions
- `terraform.tfvars.example`: Example variables file
- `build.sh`: Build script for Terraform deployment
- `cloud-init/`: Template files for customizing deployed VMs
  - `meta-data.tftpl`: Instance metadata template
  - `user-data.tftpl`: User configuration template

## Outputs

After successful deployment, the following information is displayed:

- **VM IPs**: The IP addresses of all created VMs
- **VM IDs**: The vSphere IDs of all created VMs

## Notes

* VMs are created in parallel based on the `vm_count` variable
* The default user for SSH access is "ubuntu"
* The default networking configuration uses DHCP
* VM folder is created if it doesn't exist
* VMs deployed from the template will have Docker 27.5.1 pre-installed
* Remote-exec provisioner runs basic post-deployment configuration

## Troubleshooting

If you encounter issues during deployment:

1. Verify your vSphere credentials and permissions
2. Check that the template exists and is accessible
3. Ensure your SSH key is correctly specified
4. Verify network connectivity to the vSphere environment
5. Check that the VM folder path is valid
6. For SSH connection issues, verify that the VMs have network connectivity 