terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

resource "proxmox_vm_qemu" "ubuntu_vm" {
  count       = var.vm_count
  name        = "${var.vm_name_prefix}-${count.index + 1}"
  desc        = "Ubuntu 24.04 Server"
  target_node = var.proxmox_node

  clone       = var.template_name
  full_clone  = var.full_clone

  cores       = var.cores
  sockets     = var.sockets
  memory      = var.memory
  agent       = 1
  
  bootdisk    = "scsi0"
  scsihw      = "virtio-scsi-pci"
  
  disk {
    size      = var.disk_size
    type      = "scsi"
    storage   = var.storage_pool
    iothread  = 1
  }
  
  network {
    model     = "virtio"
    bridge    = var.vm_network_bridge
  }
  
  os_type     = "cloud-init"
  ipconfig0   = "ip=dhcp"
  
  ciuser      = var.ci_user
  cipassword  = var.ci_password
  sshkeys     = file(var.ssh_public_key_path)

  # Cloud-init configurations
  cicustom = "user=local:snippets/${var.vm_name_prefix}-${count.index + 1}-user.yml"

  # Create the cloud-init config files on the Proxmox server
  provisioner "file" {
    content     = templatefile("${path.module}/cloud-init/user.yml.tpl", {
      hostname = "${var.vm_name_prefix}-${count.index + 1}"
      fqdn     = "${var.vm_name_prefix}-${count.index + 1}.${var.domain}"
    })
    destination = "/var/lib/vz/snippets/${var.vm_name_prefix}-${count.index + 1}-user.yml"
    
    connection {
      type     = "ssh"
      user     = var.proxmox_ssh_user
      password = var.proxmox_ssh_password
      host     = var.proxmox_host
    }
  }

  # Wait for cloud-init to complete and VM to be ready
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
    
    connection {
      type        = "ssh"
      user        = var.ci_user
      private_key = file(var.ssh_private_key_path)
      host        = self.default_ipv4_address
    }
  }
}

output "vm_ips" {
  value = {
    for idx, vm in proxmox_vm_qemu.ubuntu_vm : vm.name => vm.default_ipv4_address
  }
  description = "The IP addresses of the created VMs"
}

output "vm_ids" {
  value = {
    for idx, vm in proxmox_vm_qemu.ubuntu_vm : vm.name => vm.id
  }
  description = "The IDs of the created VMs"
}
