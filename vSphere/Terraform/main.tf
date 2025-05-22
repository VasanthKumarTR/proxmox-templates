terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.12.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_vcenter
  allow_unverified_ssl = true
}

# Define VMware vSphere 
data "vsphere_datacenter" "dc" {
  name = var.vsphere-datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm-datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere-cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm-network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "/${var.vsphere-datacenter}/vm/${var.vsphere-template-folder}/${var.vm-template-name}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  for_each = local.vms

  name             = each.value.name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus             = each.value.cpu
  num_cores_per_socket = var.cores-per-socket
  memory               = each.value.ram
  guest_id             = var.vm-guest-id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "${each.value.name}-disk"
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    size             = each.value.disksize
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  # Create template vars specific to each VM by merging common vars with VM-specific vars
  extra_config = {
    "guestinfo.metadata" = base64encode(templatefile("${path.module}/templates/metadata.yaml", merge(local.common_templatevars, {
      name         = each.value.name,
      ipv4_address = each.value.ipv4_address
    })))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = base64encode(templatefile("${path.module}/templates/userdata.yaml", merge(local.common_templatevars, {
      name = each.value.name
    })))
    "guestinfo.userdata.encoding" = "base64"
  }

  lifecycle {
    ignore_changes = [
      annotation,
      clone[0].template_uuid,
      clone[0].customize[0].dns_server_list,
      clone[0].customize[0].network_interface[0]
    ]
  }
  firmware                = "efi"
  efi_secure_boot_enabled = false
}
