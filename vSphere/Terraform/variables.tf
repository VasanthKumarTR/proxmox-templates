variable "vsphere_user" {
  type        = string
  description = "vSphere username"
}

variable "vsphere_password" {
  type        = string
  sensitive   = true
  description = "vSphere password"
}

variable "vsphere_server" {
  type        = string
  description = "vSphere server address"
}

variable "allow_unverified_ssl" {
  type        = bool
  default     = true
  description = "Allow unverified SSL certificate"
}

variable "datacenter" {
  type        = string
  description = "vSphere datacenter name"
}

variable "datastore" {
  type        = string
  description = "vSphere datastore name"
}

variable "cluster" {
  type        = string
  description = "vSphere cluster name"
}

variable "network" {
  type        = string
  description = "vSphere network name"
}

variable "template_name" {
  type        = string
  description = "VM template name to clone from"
}

variable "vm_folder" {
  type        = string
  description = "VM folder to create VMs in"
}

variable "vm_name_prefix" {
  type        = string
  default     = "ubuntu24"
  description = "Prefix for VM names"
}

variable "domain" {
  type        = string
  default     = "local"
  description = "Domain name for VMs"
}

variable "vm_count" {
  type        = number
  default     = 1
  description = "Number of VMs to create"
}

variable "num_cpus" {
  type        = number
  default     = 2
  description = "Number of vCPUs for the VM"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Memory in MB for the VM"
}

variable "disk_size" {
  type        = number
  default     = 0
  description = "Disk size in GB (0 means use template's disk size)"
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "SSH username for remote access"
}

variable "ssh_private_key_path" {
  type        = string
  description = "Path to SSH private key for remote access"
}