###############################################################################
# TERRAFORM CONFIGURATION
###############################################################################
# This block configures Terraform itself, including required providers
# and their versions. This ensures consistency across deployments.
###############################################################################
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere" # The source of the vSphere provider
      version = "2.12.0"            # The specific version of the provider to use
    }
  }
}

###############################################################################
# PROVIDER CONFIGURATION
###############################################################################
# The provider block configures the specified provider, in this case VMware vSphere.
# This includes authentication details and connection parameters.
###############################################################################
provider "vsphere" {
  user                 = var.vsphere_user     # vSphere username from variables
  password             = var.vsphere_password # vSphere password from variables
  vsphere_server       = var.vsphere_vcenter  # vCenter server address from variables
  allow_unverified_ssl = true                 # Skip SSL verification (for self-signed certs)
}

###############################################################################
# DATA SOURCES
###############################################################################
# Data sources allow Terraform to read attributes from existing infrastructure.
# Here we're getting information about vSphere objects we need for our VMs.
###############################################################################

# Get information about the datacenter
data "vsphere_datacenter" "dc" {
  name = var.vsphere-datacenter # The name of the datacenter in vSphere
}

# Get information about the datastore where VMs will be stored
data "vsphere_datastore" "datastore" {
  name          = var.vm-datastore              # The name of the datastore
  datacenter_id = data.vsphere_datacenter.dc.id # Reference to the datacenter above
}

# Get information about the compute cluster where VMs will run
data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere-cluster           # The name of the cluster
  datacenter_id = data.vsphere_datacenter.dc.id # Reference to the datacenter above
}

# Get information about the network where VMs will be connected
data "vsphere_network" "network" {
  name          = var.vm-network                # The name of the network
  datacenter_id = data.vsphere_datacenter.dc.id # Reference to the datacenter above
}

# Get information about the template that will be used to create VMs
data "vsphere_virtual_machine" "template" {
  name          = "/${var.vsphere-datacenter}/vm/${var.vsphere-template-folder}/${var.vm-template-name}"
  datacenter_id = data.vsphere_datacenter.dc.id # Reference to the datacenter above
}

###############################################################################
# VIRTUAL MACHINE RESOURCE
###############################################################################
# This resource block creates multiple virtual machines based on the VMs defined
# in the locals block in variables.tf. Using for_each allows us to create
# multiple VMs in parallel with different configurations.
###############################################################################
resource "vsphere_virtual_machine" "vm" {
  # Create one VM for each entry in the local.vms map
  for_each = local.vms

  # Basic VM settings
  name             = each.value.name                                       # Name from the VM configuration
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id # Cluster resource pool
  datastore_id     = data.vsphere_datastore.datastore.id                   # Datastore for VM files

  # Hardware configuration
  num_cpus             = each.value.cpu       # CPU count from VM configuration
  num_cores_per_socket = var.cores-per-socket # Cores per socket from variables
  memory               = each.value.ram       # RAM amount from VM configuration
  guest_id             = var.vm-guest-id      # Guest OS identifier

  # Network configuration - each VM gets one network adapter
  network_interface {
    network_id   = data.vsphere_network.network.id                                  # Network from data source
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0] # Same adapter type as template
  }

  # Disk configuration - each VM gets one disk
  disk {
    label            = "${each.value.name}-disk"                                      # Disk label based on VM name
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned # Same provisioning as template
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub    # Same scrubbing as template
    size             = each.value.disksize                                            # Disk size from VM configuration
  }

  # Clone from template
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id # Template UUID from data source
  }

  # Cloud-init configuration for first-boot customization
  # This passes metadata and user-data to the VM, encoded in base64
  extra_config = {
    # Metadata includes network configuration and hostname
    "guestinfo.metadata" = base64encode(templatefile("${path.module}/templates/metadata.yaml", merge(local.common_templatevars, {
      name         = each.value.name,
      ipv4_address = each.value.ipv4_address
    })))
    "guestinfo.metadata.encoding" = "base64"

    # User-data includes SSH keys and packages to install
    "guestinfo.userdata" = base64encode(templatefile("${path.module}/templates/userdata.yaml", merge(local.common_templatevars, {
      name = each.value.name
    })))
    "guestinfo.userdata.encoding" = "base64"
  }

  # Lifecycle configuration to prevent unnecessary changes
  lifecycle {
    ignore_changes = [
      annotation,                                # Don't update if annotation changes
      clone[0].template_uuid,                    # Don't recreate if template UUID changes
      clone[0].customize[0].dns_server_list,     # Don't recreate if DNS servers change
      clone[0].customize[0].network_interface[0] # Don't recreate if network config changes
    ]
  }

  # Firmware configuration
  firmware                = "efi" # Use EFI firmware instead of BIOS
  efi_secure_boot_enabled = false # Disable secure boot for compatibility
}
