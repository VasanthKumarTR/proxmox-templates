packer {
  required_plugins {
    vsphere = {
      version = ">= v1.2.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

# vCenter Credentials
variable "vcenter_username" {
  type        = string
  description = "The username for authenticating to vCenter."
  default     = ""
  sensitive   = true
}

variable "vcenter_password" {
  type        = string
  description = "The plaintext password for authenticating to vCenter."
  default     = ""
  sensitive   = true
}

variable "ssh_username" {
  type        = string
  description = "The username to use to authenticate over SSH."
  default     = "ubuntu"
  sensitive   = true
}

variable "ssh_password" {
  type        = string
  description = "The plaintext password to use to authenticate over SSH."
  default     = "ubuntu"
  sensitive   = true
}

# vSphere Objects
variable "vcenter_insecure_connection" {
  type        = bool
  description = "If true, does not validate the vCenter server's TLS certificate."
  default     = true
}

variable "vcenter_server" {
  type        = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance."
  default     = ""
}

variable "vcenter_datacenter" {
  type        = string
  description = "Required if there is more than one datacenter in vCenter."
  default     = ""
}

variable "vcenter_host" {
  type        = string
  description = "The ESXi host where target VM is created."
  default     = ""
}

variable "vcenter_cluster" {
  type        = string
  description = "The cluster where target VM is created."
  default     = ""
}

variable "vcenter_datastore" {
  type        = string
  description = "Required for clusters, or if the target host has multiple datastores."
  default     = ""
}

variable "vcenter_network" {
  type        = string
  description = "The network segment or port group name to which the primary virtual network adapter will be connected."
  default     = ""
}

variable "vcenter_folder" {
  type        = string
  description = "The VM folder in which the VM template will be created."
  default     = ""
}

# ISO Objects
variable "iso_path" {
  type        = string
  description = "The path on the source vSphere datastore for ISO images."
  default     = ""
}

variable "iso_url" {
  type        = string
  description = "The url to retrieve the iso image"
  default     = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
}

variable "iso_file" {
  type        = string
  description = "The file name of the guest operating system ISO image installation media."
  default     = ""
}

variable "iso_checksum" {
  type        = string
  description = "The checksum of the ISO image."
  default     = "d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
}

variable "iso_checksum_type" {
  type        = string
  description = "The checksum type of the ISO image. Ex: sha256"
  default     = "sha256"
}

# HTTP Endpoint
variable "http_directory" {
  type        = string
  description = "Directory of config files(user-data, meta-data)."
  default     = "http"
}

# Virtual Machine Settings
variable "vm_name" {
  type        = string
  description = "The template vm name"
  default     = "Ubuntu-2404-Template"
}

variable "vm_guest_os_type" {
  type        = string
  description = "The guest operating system type, also know as guestid."
  default     = "ubuntu64Guest"
}

variable "vm_version" {
  type        = number
  description = "The VM virtual hardware version."
  default     = 19
}

variable "vm_firmware" {
  type        = string
  description = "The virtual machine firmware. (e.g. 'bios' or 'efi')"
  default     = "efi"
}

variable "vm_cdrom_type" {
  type        = string
  description = "The virtual machine CD-ROM type."
  default     = "sata"
}

variable "vm_cpu_sockets" {
  type        = number
  description = "The number of virtual CPUs sockets."
  default     = 1
}

variable "vm_cpu_cores" {
  type        = number
  description = "The number of virtual CPUs cores per socket."
  default     = 2
}

variable "vm_mem_size" {
  type        = number
  description = "The size for the virtual memory in MB."
  default     = 2048
}

variable "vm_disk_size" {
  type        = number
  description = "The size for the virtual disk in MB."
  default     = 20480
}

variable "thin_provision" {
  type        = bool
  description = "Thin or Thick provisioning of the disk"
  default     = true
}

variable "disk_eagerly_scrub" {
  type        = bool
  description = "eagrly scrub zeros"
  default     = false
}

variable "vm_disk_controller_type" {
  type        = list(string)
  description = "The virtual disk controller types in sequence."
  default     = ["pvscsi"]
}

variable "vm_network_card" {
  type        = string
  description = "The virtual network card type."
  default     = "vmxnet3"
}

variable "vm_boot_wait" {
  type        = string
  description = "The time to wait before boot."
  default     = "10s"
}

variable "shell_scripts" {
  type        = list(string)
  description = "A list of scripts."
  default     = []
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

source "vsphere-iso" "ubuntu-2404" {
  vcenter_server       = var.vcenter_server
  username             = var.vcenter_username
  password             = var.vcenter_password
  datacenter           = var.vcenter_datacenter
  datastore            = var.vcenter_datastore
  host                 = var.vcenter_host
  cluster              = var.vcenter_cluster
  folder               = var.vcenter_folder
  insecure_connection  = var.vcenter_insecure_connection
  tools_upgrade_policy = true
  remove_cdrom         = true
  convert_to_template  = true
  guest_os_type        = var.vm_guest_os_type
  vm_version           = var.vm_version
  notes                = "Ubuntu 24.04 Template built by Packer on ${local.buildtime}"
  vm_name              = var.vm_name
  firmware             = var.vm_firmware
  CPUs                 = var.vm_cpu_sockets
  cpu_cores            = var.vm_cpu_cores
  CPU_hot_plug         = false
  RAM                  = var.vm_mem_size
  RAM_hot_plug         = false
  cdrom_type           = var.vm_cdrom_type
  disk_controller_type = var.vm_disk_controller_type
  storage {
    disk_size             = var.vm_disk_size
    disk_controller_index = 0
    disk_thin_provisioned = var.thin_provision
    disk_eagerly_scrub    = var.disk_eagerly_scrub
  }
  network_adapters {
    network      = var.vcenter_network
    network_card = var.vm_network_card
  }
  iso_url      = var.iso_url
  iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"

  # We'll use CD-ROM based cloud-init like in our Proxmox setup
  cd_files = [
    "./${var.http_directory}/meta-data",
    "./${var.http_directory}/user-data"
  ]
  cd_label = "cidata"

  boot_order = "disk,cdrom"
  boot_wait  = var.vm_boot_wait

  # Boot command for Ubuntu 24.04 (BIOS boot)
  boot_command = [
    "<esc><wait>",
    "c<wait>",
    "linux /casper/vmlinuz quiet autoinstall ds=nocloud<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

  ip_wait_timeout        = "20m"
  ssh_password           = var.ssh_password
  ssh_username           = var.ssh_username
  ssh_port               = 22
  ssh_timeout            = "30m"
  ssh_handshake_attempts = "100"
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout       = "15m"
}

##################################################################################
# BUILD
##################################################################################

build {
  sources = ["source.vsphere-iso.ubuntu-2404"]

  # Wait for cloud-init to finish and configure VM tools
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "echo 'Cloud-init finished...'",
      "sudo systemctl enable open-vm-tools",
      "sudo systemctl start open-vm-tools",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "echo 'Ubuntu 24.04 Template by Packer - Creation Date: $(date)' | sudo tee /etc/issue"
    ]
  }

  # Install Docker 27.5.1
  provisioner "shell" {
    inline = [
      "echo 'Installing Docker...'",
      "# Add Docker's official GPG key",
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",

      "# Add the Docker repository",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",

      "# Pin Docker version",
      "echo 'Package: docker-ce' | sudo tee /etc/apt/preferences.d/docker-ce",
      "echo 'Pin: version 5:27.5.1*' | sudo tee -a /etc/apt/preferences.d/docker-ce",
      "echo 'Pin-Priority: 999' | sudo tee -a /etc/apt/preferences.d/docker-ce",

      "# Install Docker",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce=5:27.5.1* docker-ce-cli=5:27.5.1* containerd.io docker-buildx-plugin docker-compose-plugin",

      "# Add ubuntu user to docker group",
      "sudo usermod -aG docker ubuntu",

      "# Enable Docker service",
      "sudo systemctl enable docker",

      "# Verify installation",
      "docker --version",
      "docker compose version",

      "echo 'Docker installation complete!'"
    ]
  }

  # Final cleanup
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

  # Prepare for template conversion
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
      "echo 'ExecStartPre=/bin/sh -c \"if [ -e /dev/zero ]; then rm -f /etc/ssh/ssh_host_* && ssh-keygen -A; fi\"' | sudo tee -a /etc/systemd/system/ssh.service.d/regenerate_ssh_host_keys.conf",
      "echo 'Setting disk as boot device...'",
      "sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub",
      "sudo update-grub",
      "echo 'Clearing cloud-init status to ensure fresh start on first boot...'",
      "sudo cloud-init clean --logs",
      "echo 'Installation and cleanup completed successfully!'"
    ]
  }
}
