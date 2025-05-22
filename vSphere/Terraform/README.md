# vSphere Ubuntu 24.04 VM Terraform Configuration

This Terraform configuration allows you to easily provision Ubuntu 24.04 virtual machines on a vSphere environment from your pre-built template.

## Versions Used

This configuration has been tested with the following specific versions:

- **vSphere vCenter**: 7.0.3.01800 (Build number: 22837322)
- **ESXi host**: v6.7
- **Terraform**: v1.5.7
- **Ubuntu**: 24.04 LTS (using ubuntu-24.04.2-live-server-amd64.iso)
- **vSphere Provider**: 2.12.0

## Prerequisites

* Terraform installed (version 1.5.7+)
* Access to a vSphere environment with vCenter 7.0.3+ and ESXi 6.7+
* Ubuntu 24.04 template created with the Packer configuration in the `../Packer` directory

## Features

* Deploy multiple VMs in parallel using for_each
* Customize VM resources (CPU, memory, disk)
* Static or DHCP IP address configuration
* Cloud-init integration for first-boot customization
* SSH key injection for secure access
* EFI firmware support for modern boot

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` (if not already present)
2. Ensure `vars.auto.tfvars` is configured with your environment-specific settings
3. Modify the VM definitions in the `locals` block of `variables.tf` as needed
4. Run the commands manually:

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Creating Multiple VMs in Parallel

The configuration uses the `for_each` meta-argument to create multiple VMs in parallel. The VM definitions are in a `locals` block in `variables.tf`:

```hcl
locals {
  # Define multiple VMs with their specific configurations
  vms = {
    "vm1" = {
      name         = "ubuntu24-04-vm1"
      ipv4_address = "192.168.1.97"
      cpu          = var.cpu
      ram          = var.ram
      disksize     = var.disksize
    },
    "vm2" = {
      name         = "ubuntu24-04-vm2"
      ipv4_address = "192.168.1.98"
      cpu          = var.cpu
      ram          = var.ram
      disksize     = var.disksize
    }
    # Add more VMs as needed
  }

  # Common template variables for all VMs
  common_templatevars = {
    ipv4_gateway = var.ipv4_gateway,
    dns_server_1 = var.dns_server_list[0],
    dns_server_2 = var.dns_server_list[1],
    public_key   = var.public_key,
    ssh_username = var.ssh_username
  }
}
```

To add more VMs, simply add more entries to the `vms` map with the desired configuration.

## Project Structure

- **main.tf**: Main Terraform configuration for VM deployment using for_each
- **variables.tf**: Variable definitions and VM configuration via locals block
- **output.tf**: Outputs for all created VM IP addresses and names
- **templates/**: Template files for customizing deployed VMs
  - **metadata.yaml**: Instance metadata template
  - **userdata.yaml**: User configuration template

## Configuration Options

The configuration uses the following variables:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| cpu | Number of vCPUs for the VM | 1 |
| cores-per-socket | Number of cores per socket | 1 |
| ram | Memory in MB for the VM | 2048 |
| disksize | Disk size in GB | 40 |
| vm-guest-id | Guest OS identifier | "ubuntu64Guest" |
| vsphere-unverified-ssl | Allow unverified SSL certs | "true" |
| vsphere-datacenter | vSphere datacenter name | "Datacenter" |
| vsphere-cluster | vSphere cluster name | "Cluster01" |
| vm-datastore | vSphere datastore name | "Datastore2_NonSSD" |
| vm-network | vSphere network name | "VM Network" |
| vm-domain | Domain name for VMs | "home" |
| dns_server_list | List of DNS servers | ["8.8.8.8", "8.8.4.4"] |
| ipv4_gateway | Default gateway | "192.168.1.254" |
| ipv4_netmask | Network mask | "24" |
| vm-template-name | VM template name to clone from | "Ubuntu-2404-Template" |
| vsphere_user | vSphere username | (Required) |
| vsphere_password | vSphere password | (Required) |
| vsphere_vcenter | vSphere server address | (Required) |
| ssh_username | SSH username for remote access | (Required) |
| public_key | SSH public key for VM access | (Required) |

## Output Values

The configuration provides the following outputs:

```hcl
output "ip_addresses" {
  description = "IP addresses of all created virtual machines"
  value = {
    for k, v in vsphere_virtual_machine.vm : k => v.guest_ip_addresses[0]
  }
}

output "vm_names" {
  description = "Names of all created virtual machines"
  value = {
    for k, v in vsphere_virtual_machine.vm : k => v.name
  }
}
```

## Cloud-Init Configuration

This configuration uses vSphere's cloud-init integration to customize VMs at first boot:

1. **SSH Key Injection**: Your public SSH key is automatically injected into authorized_keys
2. **Network Configuration**: Each VM is configured with static IP or DHCP
3. **Hostname Configuration**: Each VM gets the configured hostname
4. **Package Installation**: Basic packages are installed on first boot

## Firmware Configuration

The VMs are configured to use EFI firmware for modern boot capabilities, with secure boot disabled:

```hcl
firmware                = "efi"
efi_secure_boot_enabled = false
```

## Troubleshooting

If you encounter issues during deployment:

1. Verify your vSphere credentials and permissions
2. Check that the template exists and is accessible
3. Ensure the VM template was created with EFI firmware if using EFI boot
4. Verify network connectivity to the vSphere environment
5. For boot issues, check that the VM firmware (EFI/BIOS) matches the template 