#===========================#
# VMware vCenter connection #
#===========================#
# These variables are used for authenticating with vCenter Server.
# They are marked as sensitive to prevent their values from being
# displayed in console output or logs.
#===========================#

variable "vsphere_user" {
  type        = string
  description = "VMware vSphere user name"
  sensitive   = true # Marked sensitive to hide in logs and console output
}

variable "vsphere_password" {
  type        = string
  description = "VMware vSphere password"
  sensitive   = true # Marked sensitive to hide in logs and console output
}

variable "vsphere_vcenter" {
  type        = string
  description = "VMWare vCenter server FQDN / IP"
  sensitive   = true # Marked sensitive to hide in logs and console output
}

variable "vsphere-unverified-ssl" {
  type        = string
  description = "Is the VMware vCenter using a self signed certificate (true/false)"
  # Set to 'true' if using self-signed certificates in vCenter
}

#===========================#
# vSphere Infrastructure    #
#===========================#
# These variables define the existing vSphere infrastructure components
# where VMs will be deployed, such as datacenter, cluster, and template folder.
#===========================#

variable "vsphere-datacenter" {
  type        = string
  description = "VMWare vSphere datacenter"
  # The name of the datacenter in vSphere where VMs will be deployed
}

variable "vsphere-cluster" {
  type        = string
  description = "VMWare vSphere cluster"
  default     = ""
  # The name of the cluster within the datacenter where VMs will be deployed
}

variable "vsphere-template-folder" {
  type        = string
  description = "Template folder"
  default     = "Templates"
  # The folder where VM templates are stored in vSphere
}

#================================#
# VMware vSphere virtual machine #
#================================#
# These variables define the configuration for the virtual machines
# that will be created. Default values are provided where appropriate.
#================================#

# Note: The VM names and IP addresses are now defined in the locals block at the end of this file

variable "vm-name-prefix" {
  type        = string
  description = "Name of VM prefix (for use in display names, not used with for_each implementation)"
  default     = "ubuntu24"
  # This prefix is used for naming VMs in traditional deployments (not used with for_each)
}

variable "vm-datastore" {
  type        = string
  description = "Datastore used for the vSphere virtual machines"
  # The datastore where VM files will be stored
}

variable "vm-network" {
  type        = string
  description = "Network used for the vSphere virtual machines"
  # The network to which VMs will be connected
}

variable "vm-linked-clone" {
  type        = string
  description = "Use linked clone to create the vSphere virtual machine from the template (true/false). If you would like to use the linked clone feature, your template need to have one and only one snapshot"
  default     = "false"
  # Linked clones use less disk space but require a snapshot on the template
}

#===========================#
# VM Hardware Configuration #
#===========================#
# These variables define the hardware resources allocated to the VMs.
# They serve as defaults and can be overridden in the VM-specific
# configuration in the locals block.
#===========================#

variable "cpu" {
  description = "Number of vCPU for the vSphere virtual machines (default value, can be overridden per VM in locals)"
  default     = 2
  # The number of virtual CPUs allocated to each VM
}

variable "cores-per-socket" {
  description = "Number of cores per cpu for workers"
  default     = 1
  # How many cores per socket (affects performance and licensing)
}

variable "ram" {
  description = "Amount of RAM for the vSphere virtual machines in MB (default value, can be overridden per VM in locals)"
  # The amount of memory allocated to each VM in megabytes
}

variable "disksize" {
  description = "Disk size in GB (default value, can be overridden per VM in locals)"
  default     = 40
  # The size of the primary disk in gigabytes
}

#===========================#
# VM Operating System       #
#===========================#
# These variables define the operating system and networking configuration
# for the VMs being deployed.
#===========================#

variable "vm-guest-id" {
  type        = string
  description = "The ID of virtual machines operating system"
  # The vSphere guest ID that identifies the operating system (e.g., "ubuntu64Guest")
}

variable "vm-template-name" {
  type        = string
  description = "The template to clone to create the VM"
  # The name of the template from which VMs will be cloned
}

variable "vm-domain" {
  type        = string
  description = "Linux virtual machine domain name for the machine. This, along with host_name, make up the FQDN of the virtual machine"
  default     = ""
  # The DNS domain name for the VMs
}

#===========================#
# Network Configuration     #
#===========================#
# These variables define the network settings for the VMs,
# including DNS servers, gateway, and netmask.
#===========================#

variable "dns_server_list" {
  type        = list(string)
  description = "List of DNS servers"
  default     = ["8.8.8.8", "8.8.4.4"]
  # List of DNS servers the VMs will use
}

variable "ipv4_gateway" {
  type        = string
  description = "Default gateway for the network"
  # The default gateway IP address for the network
}

variable "ipv4_netmask" {
  type        = string
  description = "Network mask (e.g., 24 for a /24 network)"
  # The network mask in CIDR notation (e.g., 24 for a /24 network)
}

#===========================#
# Authentication            #
#===========================#
# These variables define how users will authenticate to the VMs.
# SSH keys are the primary method of authentication.
#===========================#

variable "ssh_username" {
  type        = string
  description = "SSH username for VM access"
  sensitive   = true
  default     = "ubuntu"
  # The username that will be created on the VMs and used for SSH access
}

variable "public_key" {
  type        = string
  description = "Public key to be used to ssh into a machine"
  default     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCb7fcDZfIG+SxuP5UsZaoHPdh9MNxtEL5xRI71hzMS5h4SsZiPGEP4shLcF9YxSncdOJpyOJ6OgumNSFWj2pCd/kqg9wQzk/E1o+FRMbWX5gX8xMzPig8mmKkW5szhnP+yYYYuGUqvTAKX4ua1mQwL6PipWKYJ1huJhgpGHrvSQ6kuywJ23hw4klcaiZKXVYtvTi8pqZHhE5Kx1237a/6GRwnbGLEp0UR2Q/KPf6yRgZIrCdD+AtOznSBsBhf5vqcfnnwEIC/DOnqcOTahBVtFhOKuPSv3bUikAD4Vw7SIRteMltUVkd/O341fx+diKOBY7a8M6pn81HEZEmGsr7rT sam@SamMac.local"
  # The SSH public key that will be added to authorized_keys on the VMs
}

#================================#
# VM Configuration               #
#================================#
# This locals block defines the specific VMs to create and their
# individual configurations. This is the main place to add or modify VMs.
#================================#

locals {
  # Define multiple VMs with their specific configurations
  vms = {
    "vm1" = {
      name         = "ubuntu24-04-vm1" # Name of the first VM
      ipv4_address = "192.168.1.97"    # Static IP address for the first VM
      cpu          = var.cpu           # Use the default CPU count
      ram          = var.ram           # Use the default RAM amount
      disksize     = var.disksize      # Use the default disk size
    },
    "vm2" = {
      name         = "ubuntu24-04-vm2" # Name of the second VM
      ipv4_address = "192.168.1.98"    # Static IP address for the second VM
      cpu          = var.cpu           # Use the default CPU count
      ram          = var.ram           # Use the default RAM amount
      disksize     = var.disksize      # Use the default disk size
    }
    # Add more VMs as needed by adding more entries to this map
  }

  # Common template variables for all VMs
  # These values are passed to the cloud-init templates for VM customization
  common_templatevars = {
    ipv4_gateway = var.ipv4_gateway,       # Default gateway for all VMs
    dns_server_1 = var.dns_server_list[0], # Primary DNS server
    dns_server_2 = var.dns_server_list[1], # Secondary DNS server
    public_key   = var.public_key,         # SSH public key for authentication
    ssh_username = var.ssh_username        # SSH username for the VMs
  }
}
