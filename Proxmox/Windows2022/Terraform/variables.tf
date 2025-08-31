variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token (format: PVEAPIToken=user@realm!tokenid=secret)"
  type        = string
  sensitive   = true
}

variable "target_node" {
  description = "Proxmox node to create the VM on"
  type        = string
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

variable "gateway" {
  description = "Network gateway IP address"
  type        = string
  default     = "172.16.0.1"
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "dns_domain" {
  description = "DNS domain name"
  type        = string
  default     = "local"
}

variable "vm_password" {
  description = "Password for the Administrator user"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd123!"
}

variable "template_name" {
  description = "Name of the Proxmox template to clone from"
  type        = string
  default     = "windows-server-2022-template"
}

variable "vm_id_start" {
  description = "Starting VM ID for created VMs (will increment for each VM)"
  type        = number
  default     = 9200
}

variable "vms" {
  description = "Map of Windows VMs to create with their configurations"
  type = map(object({
    ip_address = string
    cores      = number
    memory     = number
    disk_size  = string
  }))
  default = {
    "win2022-server1" = {
      ip_address = "172.16.11.100/24"
      cores      = 4
      memory     = 4096
      disk_size  = "80"
    }
    "win2022-server2" = {
      ip_address = "172.16.11.101/24"
      cores      = 2
      memory     = 4096
      disk_size  = "60"
    }
  }
}
