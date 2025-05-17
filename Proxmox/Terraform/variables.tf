variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "ubuntu-vm"
}

variable "target_node" {
  description = "Proxmox node to create the VM on"
  type        = string
}

variable "vm_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Amount of memory in MB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Disk size for the VM (in GB)"
  type        = string
  default     = "20"
}

variable "disk_storage" {
  description = "Storage location for the VM disk"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
  default     = "vmbr0"
}

variable "static_ip_address" {
  description = "Static IP address for the VM (including CIDR notation, e.g., 192.168.1.96/24)"
  type        = string
  default     = "192.168.1.96/24"
}

variable "gateway" {
  description = "Network gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "dns_domain" {
  description = "DNS domain name"
  type        = string
  default     = "home"
}

variable "ssh_public_keys" {
  description = "SSH public keys to add to the VM"
  type        = string
  default     = ""
}

variable "vm_password" {
  description = "Password for the Ubuntu user (overrides template password)"
  type        = string
  sensitive   = true
  default     = null # If null, keeps the password from the template
}
