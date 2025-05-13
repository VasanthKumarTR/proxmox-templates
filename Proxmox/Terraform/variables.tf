variable "proxmox_api_url" {
  type        = string
  description = "The URL of the Proxmox API (e.g., https://proxmox.example.com:8006/api2/json)"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID (e.g., user@pam!tokenname)"
}

variable "proxmox_api_token_secret" {
  type        = string
  sensitive   = true
  description = "Proxmox API token secret"
}

variable "pm_tls_insecure" {
  type        = bool
  default     = true
  description = "Set to true to ignore certificate errors"
}

variable "proxmox_node" {
  type        = string
  description = "The name of the Proxmox node to deploy VMs on"
}

variable "proxmox_host" {
  type        = string
  description = "The hostname or IP address of the Proxmox server for SSH connections"
}

variable "proxmox_ssh_user" {
  type        = string
  description = "SSH username for the Proxmox server"
}

variable "proxmox_ssh_password" {
  type        = string
  sensitive   = true
  description = "SSH password for the Proxmox server"
}

variable "template_name" {
  type        = string
  description = "The name of the VM template to clone from"
}

variable "vm_name_prefix" {
  type        = string
  default     = "ubuntu24"
  description = "Prefix for VM names"
}

variable "domain" {
  type        = string
  default     = "local"
  description = "Domain name for the VMs"
}

variable "vm_count" {
  type        = number
  default     = 1
  description = "Number of VMs to create"
}

variable "full_clone" {
  type        = bool
  default     = true
  description = "Create a full clone instead of a linked clone"
}

variable "cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores for the VM"
}

variable "sockets" {
  type        = number
  default     = 1
  description = "Number of CPU sockets for the VM"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Memory in MB for the VM"
}

variable "disk_size" {
  type        = string
  default     = "20G"
  description = "Disk size for the VM"
}

variable "storage_pool" {
  type        = string
  default     = "local-lvm"
  description = "Storage pool to place VM disks"
}

variable "vm_network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "Bridge to use for VM networking"
}

variable "ci_user" {
  type        = string
  default     = "ubuntu"
  description = "Username to create via cloud-init"
}

variable "ci_password" {
  type        = string
  sensitive   = true
  description = "Password for the cloud-init user"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to SSH public key file to authorize for cloud-init user"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key file for accessing the created VMs"
}