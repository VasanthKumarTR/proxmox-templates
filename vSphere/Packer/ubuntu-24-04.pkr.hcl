packer {
  required_plugins {
    vsphere = {
      version = ">= v1.2.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

variable "vcenter_server" {
  type        = string
  description = "vCenter server hostname or IP address"
}

variable "vcenter_username" {
  type        = string
  description = "vCenter username"
}

variable "vcenter_password" {
  type        = string
  sensitive   = true
  description = "vCenter password"
}

variable "vcenter_insecure_connection" {
  type        = bool
  default     = true
  description = "If true, does not validate the vCenter server's TLS certificate"
}

variable "datacenter" {
  type        = string
  description = "vSphere datacenter name"
}

variable "cluster" {
  type        = string
  description = "vSphere cluster name"
}

variable "datastore" {
  type        = string
  description = "vSphere datastore name"
}

variable "folder" {
  type        = string
  description = "VM folder to create the VM in"
}

variable "network" {
  type        = string
  description = "VM network name"
}

variable "host" {
  type        = string
  description = "ESXi host to build on"
}

variable "iso_path" {
  type        = string
  default     = "[datastore1] ISO/ubuntu-24.04-live-server-amd64.iso"
  description = "Path to Ubuntu ISO file on datastore"
}

variable "iso_url" {
  type        = string
  default     = "https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso"
  description = "URL to download the Ubuntu ISO from if not present on datastore"
}

variable "iso_checksum" {
  type        = string
  default     = "sha256:45f873de9f8cb637345d6e66a583762730bbcb25a4f0c02b3af6016dad78e359"
  description = "Checksum of the ISO file"
}

variable "vm_name" {
  type        = string
  default     = "ubuntu-24-04-template"
  description = "Name of the VM template"
}

variable "vm_cpu_num" {
  type        = number
  default     = 2
  description = "Number of CPU cores for the VM"
}

variable "vm_mem_size" {
  type        = number
  default     = 2048
  description = "Memory size in MB for the VM"
}

variable "vm_disk_size" {
  type        = number
  default     = 20000
  description = "Disk size in MB for the VM"
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "Username to use for SSH access during build"
}

variable "ssh_password" {
  type        = string
  default     = "ubuntu"
  sensitive   = true
  description = "Password to use for SSH access during build"
}

source "vsphere-iso" "ubuntu_2404" {
  vcenter_server        = var.vcenter_server
  username              = var.vcenter_username
  password              = var.vcenter_password
  insecure_connection   = var.vcenter_insecure_connection

  datacenter            = var.datacenter
  cluster               = var.cluster
  datastore             = var.datastore
  folder                = var.folder
  host                  = var.host
  
  vm_name               = var.vm_name
  convert_to_template   = true
  
  notes                 = "Ubuntu 24.04 Template built by Packer on ${timestamp()}"
  guest_os_type         = "ubuntu64Guest"
  
  CPUs                  = var.vm_cpu_num
  RAM                   = var.vm_mem_size
  firmware              = "efi"
  
  disk_controller_type  = ["pvscsi"]
  storage {
    disk_size             = var.vm_disk_size
    disk_thin_provisioned = true
  }
  
  network_adapters {
    network               = var.network
    network_card          = "vmxnet3"
  }
  
  iso_paths             = [var.iso_path]
  iso_url               = var.iso_url
  iso_checksum          = var.iso_checksum
  
  http_directory        = "http"
  
  boot_wait             = "5s"
  boot_command          = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  
  ssh_username          = var.ssh_username
  ssh_password          = var.ssh_password
  ssh_timeout           = "30m"
  
  cd_files              = []
  
  shutdown_command      = "sudo -S shutdown -P now"
  shutdown_timeout      = "15m"
  
  ip_wait_timeout       = "1h"
  tools_upgrade_policy  = true
  remove_cdrom          = true
}

build {
  name = "ubuntu-server-2404"
  sources = ["source.vsphere-iso.ubuntu_2404"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "echo 'Cloud-init finished...'",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y open-vm-tools"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Installing additional packages...'",
      "sudo apt-get install -y vim net-tools htop iotop nmon",
      "sudo apt-get install -y python3-pip git unzip jq",
      "sudo apt-get install -y openssh-server fail2ban"
    ]
  }
  
  provisioner "shell" {
    inline = [
      "echo 'Setting up VMware tools...'",
      "sudo apt-get install -y open-vm-tools cloud-init",
      "sudo systemctl enable open-vm-tools",
      "sudo systemctl start open-vm-tools"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Cleaning up...'",
      "sudo apt-get autoremove -y",
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -f /var/cache/apt/archives/*.deb",
      "sudo rm -f /var/cache/apt/archives/partial/*.deb",
      "sudo rm -f /var/cache/apt/*.bin",
      "sudo cloud-init clean"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Preparing for template conversion...'",
      "sudo rm -f /etc/machine-id",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo ln -s /etc/machine-id /var/lib/dbus/machine-id",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo mkdir -p /etc/systemd/system/ssh.service.d/",
      "echo '[Service]' | sudo tee /etc/systemd/system/ssh.service.d/regenerate_ssh_host_keys.conf",
      "echo 'ExecStartPre=/bin/sh -c \"if [ -e /dev/zero ]; then rm -f /etc/ssh/ssh_host_* && ssh-keygen -A; fi\"' | sudo tee -a /etc/systemd/system/ssh.service.d/regenerate_ssh_host_keys.conf"
    ]
  }
}
