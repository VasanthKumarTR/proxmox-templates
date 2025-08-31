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
  default     = "https://172.16.11.1:8006/api2/json"
}

variable "proxmox_username" {
  type        = string
  description = "The Proxmox username for API operations"
  default     = "root@pam"
}

variable "proxmox_token" {
  type        = string
  description = "The Proxmox API token"
  sensitive   = true
}

variable "proxmox_node" {
  type        = string
  description = "The Proxmox node to build on"
  default     = "aqua"
}

# VM Identification
variable "vm_id" {
  type        = string
  description = "The ID for the VM template"
  default     = "9100"
}

# VM ISO Settings
variable "iso_file" {
  type        = string
  description = "The ISO file to use for installation"
  default     = "local:iso/en-us_windows_server_2022_updated_jan_2024_x64_dvd_2b7a0c9f.iso"
}

variable "iso_checksum" {
  type        = string
  description = "The checksum for the ISO file"
  default     = "sha256:c3c57bb2cf723973a7dcfb1a21e97dfa035753a7f111e348ad918bb64b3114db"
}

variable "virtio_iso_file" {
  type        = string
  description = "The VirtIO drivers ISO file"
  default     = "local:iso/virtio-win-0.1.248.iso"
}

# VM Credentials
variable "winrm_username" {
  type        = string
  description = "The username to use for WinRM"
  default     = "Administrator"
}

variable "winrm_password" {
  type        = string
  description = "The password to use for WinRM"
  sensitive   = true
  default     = "P@ssw0rd123!"
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

source "proxmox-iso" "windows-2022" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  token                    = var.proxmox_token
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM General Settings
  vm_id                = var.vm_id
  vm_name              = "windows-2022-template"
  template_description = "Windows Server 2022 Template, built with Packer on ${local.buildtime}"

  # VM ISO Settings
  boot_iso {
    type              = "ide"
    iso_file          = var.iso_file
    unmount           = true
    keep_cdrom_device = false
    iso_checksum      = var.iso_checksum
  }

  # VirtIO drivers ISO
  additional_iso_files {
    type              = "ide"
    index             = 1
    iso_file          = var.virtio_iso_file
    unmount           = true
    keep_cdrom_device = false
  }

  # Floppy disk with answer files
  additional_iso_files {
    type              = "ide"
    index             = 2
    iso_storage_pool  = "local"
    unmount           = true
    keep_cdrom_device = false
    cd_files = [
      "./answer_files/autounattend.xml",
      "./scripts/bootstrap.ps1",
      "./scripts/setup-winrm.ps1",
      "./scripts/install-updates.ps1"
    ]
    cd_label = "PROVISION"
  }

  # VM System Settings
  qemu_agent = true
  bios       = "ovmf"
  machine    = "q35"
  cores      = "4"
  memory     = "4096"
  
  # EFI settings
  efi_config {
    efi_storage_pool  = "local-lvm"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = "60G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
    ssd          = true
    discard      = true
  }

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # Enable TPM for Windows 11/Server 2022 compatibility
  # This will be configured in Proxmox after template creation

  # Boot commands for Windows
  boot_wait = "3s"
  boot_command = [
    "<enter>"
  ]

  # Communicator Settings
  communicator   = "winrm"
  winrm_username = var.winrm_username
  winrm_password = var.winrm_password
  winrm_timeout  = "4h"
  winrm_use_ssl  = false
}

##################################################################################
# BUILD
##################################################################################

build {
  name    = "windows-2022"
  sources = ["source.proxmox-iso.windows-2022"]

  # Wait for Windows to be ready
  provisioner "powershell" {
    inline = [
      "Write-Host 'Waiting for Windows to be ready...'",
      "Get-Service | Where-Object {$_.Name -eq 'Winmgmt'} | Wait-Service -Status Running",
      "Write-Host 'Windows is ready!'"
    ]
  }

  # Install Windows Updates
  provisioner "powershell" {
    script = "./scripts/install-updates.ps1"
  }

  # Install additional software
  provisioner "powershell" {
    inline = [
      "Write-Host 'Installing Chocolatey...'",
      "Set-ExecutionPolicy Bypass -Scope Process -Force",
      "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072",
      "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))",
      "choco install googlechrome firefox 7zip notepadplusplus git -y",
      "Write-Host 'Software installation complete'"
    ]
  }

  # Configure Windows features
  provisioner "powershell" {
    inline = [
      "Write-Host 'Enabling Windows features...'",
      "Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All",
      "Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer -All",
      "Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures -All",
      "Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors -All",
      "Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging -All",
      "Install-WindowsFeature -Name Containers",
      "Write-Host 'Windows features enabled'"
    ]
  }

  # Final cleanup and Sysprep preparation
  provisioner "powershell" {
    inline = [
      "Write-Host 'Performing final cleanup...'",
      "# Clean temporary files",
      "Remove-Item -Path 'C:\\Windows\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue",
      "Remove-Item -Path 'C:\\temp\\*' -Recurse -Force -ErrorAction SilentlyContinue",
      "# Clear event logs",
      "Get-EventLog -LogName * | ForEach-Object { Clear-EventLog -LogName $_.Log }",
      "# Defragment the disk",
      "Optimize-Volume -DriveLetter C -Defrag",
      "Write-Host 'Cleanup complete'"
    ]
  }

  # Sysprep (this will shutdown the VM)
  provisioner "powershell" {
    inline = [
      "Write-Host 'Running Sysprep...'",
      "Start-Process -FilePath 'C:\\Windows\\System32\\Sysprep\\sysprep.exe' -ArgumentList '/generalize', '/oobe', '/shutdown', '/unattend:E:\\autounattend.xml' -Wait"
    ]
  }
}
