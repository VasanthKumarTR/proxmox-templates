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

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = var.vm_name
  description = "Terraform-managed Ubuntu 24.04 VM, use ubuntu@ip_address to login"
  tags        = ["terraform", "ubuntu"]
  node_name   = var.target_node

  # Use template created by Packer
  clone {
    vm_id = 9001 # Updated to match the template ID from our Packer build (ID 9001)
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

  network_device {
    bridge = var.network_bridge
  }

  # Disk configuration to resize the template's disk
  disk {
    interface    = "scsi0" # Must match the template's disk interface
    size         = var.disk_size
    file_format  = "raw" # Match template's format
    datastore_id = var.disk_storage
  }

  operating_system {
    type = "l26"
  }

  # Cloud-init configuration for the VM
  initialization {
    # Static IP configuration for primary network interface
    ip_config {
      ipv4 {
        # dhcp is default, but we can set a static IP if we want
        # dhcp
        address = var.static_ip_address
        gateway = var.gateway
      }
    }

    # DNS servers configuration
    dns {
      servers = var.dns_servers
      domain  = var.dns_domain
    }

    user_account {
      keys     = [var.ssh_public_keys]
      username = "ubuntu"
      password = var.vm_password
    }

    # Note: Hostname is set automatically to the VM name by Proxmox
    # If you need custom hostname settings, use custom_files with cloud-init config
  }
}

output "vm_ip_address" {
  description = "IP address of the created VM"
  value       = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses
}
