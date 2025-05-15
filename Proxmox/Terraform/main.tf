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
  description = "Terraform-managed Ubuntu 24.04 VM"
  tags        = ["terraform", "ubuntu"]
  node_name   = var.target_node

  # Use template created by Packer
  clone {
    vm_id = 9000 # This should match the VM ID in your Packer configuration
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

  disk {
    datastore_id = var.disk_storage
    file_format  = "raw"
    interface    = "scsi0"
    size         = var.disk_size
  }

  serial_device {}

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [var.ssh_public_keys]
      password = null
      username = "ubuntu"
    }
  }

  cdrom {
    file_id = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
  }
}

output "vm_ip_address" {
  description = "IP address of the created VM"
  value       = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses
}
