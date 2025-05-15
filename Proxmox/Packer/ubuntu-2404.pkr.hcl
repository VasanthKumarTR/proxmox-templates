packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

##################################################################################
# VARIABLES
##################################################################################

# Connection Variables
variable "proxmox_url" {
  type        = string
  description = "The Proxmox API URL"
  default     = "https://192.168.1.95:8006/api2/json"
}

variable "proxmox_username" {
  type        = string
  description = "The Proxmox username for API operations"
  default     = "root@pam!terraform"
}

variable "proxmox_token" {
  type        = string
  description = "The Proxmox API token"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "The Proxmox node to build on"
  default     = "proxmox"
}

# VM Identification
variable "vm_id" {
  type        = string
  description = "The ID for the VM template"
  default     = "9000"
}

# VM ISO Settings
variable "iso_file" {
  type        = string
  description = "The ISO file to use for installation"
  default     = "local:iso/ubuntu-24.04.2-live-server-amd64.iso"
}

variable "iso_checksum" {
  type        = string
  description = "The checksum for the ISO file"
  default     = "sha256:45f9ddf5b54cb51a0badcd27d633e587e6f176762d7cda49862095d92dfd2055"
}

# VM Credentials
variable "ssh_username" {
  type        = string
  description = "The username to use for SSH"
  default     = "ubuntu"
}

variable "ssh_password" {
  type        = string
  description = "The password to use for SSH"
  sensitive   = true
  default     = "ubuntu"
}

##################################################################################
# LOCALS
##################################################################################

locals {
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

##################################################################################
# SOURCE
##################################################################################

source "proxmox-iso" "ubuntu-2404" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM General Settings
  vm_id                = var.vm_id
  vm_name              = "ubuntu-2404-template"
  template_description = "Ubuntu 24.04 Server Template, built with Packer on ${local.buildtime}"

  # VM ISO Settings

  boot_iso {
    type         = "scsi"
    iso_file     = var.iso_file
    unmount      = true
    iso_checksum = var.iso_checksum
  }

  # Set explicit boot order - boot from installation ISO first
  boot = "order=ide2;scsi0;net0"

  # VM System Settings
  qemu_agent = true
  cores      = "2"
  memory     = "2048"

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
  }

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # Cloud-init config via additional ISO
  additional_iso_files {
    type             = "ide"
    iso_storage_pool = "local"
    unmount          = true
    cd_files = [
      "./http/meta-data",
      "./http/user-data"
    ]
    cd_label = "cidata"
  }

  # PACKER Boot Commands
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud;",
    "<f10>"
  ]

  # Communicator Settings
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"
}

##################################################################################
# BUILD
##################################################################################

build {
  name    = "ubuntu-2404"
  sources = ["source.proxmox-iso.ubuntu-2404"]

  # Provisioning the VM Template
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "echo 'Ubuntu 24.04 Template by Packer - Creation Date: $(date)' | sudo tee /etc/issue"
    ]
  }
}
