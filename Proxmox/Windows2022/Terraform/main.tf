terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true
}

resource "proxmox_virtual_environment_vm" "windows_vm" {
  for_each = var.vms

  name        = each.key
  description = "Terraform-managed Windows Server 2022 VM, use Administrator@${each.value.ip_address} to login"
  tags        = ["terraform", "windows", "server2022"]
  node_name   = var.target_node

  # Use template created by Packer
  clone {
    vm_id = 9100 # Windows Server 2022 template ID from Packer build
    full  = true
  }

  agent {
    enabled = true
  }

  # UEFI/EFI configuration for Windows
  bios = "ovmf"
  
  efi_disk {
    datastore_id      = var.disk_storage
    file_format       = "raw"
    type              = "4m"
    pre_enrolled_keys = true
  }

  # TPM configuration for Windows Server 2022
  tpm_state {
    datastore_id = var.disk_storage
    version      = "v2.0"
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # Disk configuration to resize the template's disk
  disk {
    interface    = "scsi0" # Must match the template's disk interface
    size         = each.value.disk_size
    file_format  = "raw" # Match template's format
    datastore_id = var.disk_storage
    ssd          = true
    discard      = true
  }

  operating_system {
    type = "win11" # Use win11 for Windows Server 2022 (same kernel)
  }

  # Cloud-init configuration for the VM
  initialization {
    # Static IP configuration for primary network interface
    ip_config {
      ipv4 {
        address = each.value.ip_address
        gateway = var.gateway
      }
    }

    # DNS servers configuration
    dns {
      servers = var.dns_servers
      domain  = var.dns_domain
    }

    user_account {
      username = "Administrator"
      password = var.vm_password
    }

    # Custom files for Windows-specific cloud-init configuration
    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  }

  # Ensure VM starts after template cloning
  started = true

  # Wait for the VM to be accessible via WinRM
  timeouts {
    create = "30m"
  }
}

# Cloud-init configuration file for Windows
resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each = var.vms

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = templatefile("${path.module}/cloud-init.yml.tpl", {
      hostname    = each.key
      ip_address  = split("/", each.value.ip_address)[0]
      gateway     = var.gateway
      dns_servers = var.dns_servers
      domain      = var.dns_domain
    })
    file_name = "cloud-init-${each.key}.yml"
  }
}

# Output the VM information
output "vm_ip_addresses" {
  description = "IP addresses of the created Windows VMs"
  value = {
    for k, v in proxmox_virtual_environment_vm.windows_vm : k => v.ipv4_addresses
  }
}

output "vm_connection_info" {
  description = "Connection information for the Windows VMs"
  value = {
    for k, v in var.vms : k => {
      ip_address = split("/", v.ip_address)[0]
      username   = "Administrator"
      rdp_port   = 3389
      winrm_port = 5985
    }
  }
}
