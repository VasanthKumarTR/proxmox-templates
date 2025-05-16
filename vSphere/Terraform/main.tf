terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.3.1"
    }
  }
  required_version = ">= 1.0.0"
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.allow_unverified_ssl
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folder" {
  path          = var.vm_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  count            = var.vm_count
  name             = "${var.vm_name_prefix}-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path

  num_cpus = var.num_cpus
  memory   = var.memory
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.disk_size == 0 ? data.vsphere_virtual_machine.template.disks[0].size : var.disk_size
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${var.vm_name_prefix}-${count.index + 1}"
        domain    = var.domain
      }

      network_interface {}
    }
  }

  # Extra configuration drive for cloud-init
  extra_config = {
    "guestinfo.userdata" = base64encode(templatefile("${path.module}/cloud-init/user-data.tftpl", {
      hostname          = "${var.vm_name_prefix}-${count.index + 1}"
      ssh_public_key    = var.ssh_public_key != "" ? var.ssh_public_key : file(pathexpand(var.ssh_public_key_path))
      override_password = var.override_password
      vm_password       = var.vm_password
    }))
    "guestinfo.userdata.encoding" = "base64"
    "guestinfo.metadata" = base64encode(templatefile("${path.module}/cloud-init/meta-data.tftpl", {
      hostname    = "${var.vm_name_prefix}-${count.index + 1}"
      instance_id = "${var.vm_name_prefix}-${count.index + 1}-${random_uuid.instance_id[count.index].result}"
    }))
    "guestinfo.metadata.encoding" = "base64"
  }

  lifecycle {
    ignore_changes = [
      annotation
    ]
  }

  # Wait for VMware tools to come online
  wait_for_guest_net_timeout = 10
  wait_for_guest_ip_timeout  = 10

  # Setup SSH connection for remote-exec
  connection {
    type        = "ssh"
    user        = var.ssh_username
    private_key = file(var.ssh_private_key_path)
    host        = self.default_ip_address
  }

  # Run post-deployment configuration
  provisioner "remote-exec" {
    inline = [
      "echo 'Setting hostname...'",
      "sudo hostnamectl set-hostname ${var.vm_name_prefix}-${count.index + 1}.${var.domain}",
      "echo 'Updating system...'",
      "sudo apt-get update && sudo apt-get upgrade -y",
      "echo 'Installation complete!' > ~/setup-complete.log"
    ]
  }
}

# Generate a unique instance ID for each VM for cloud-init
resource "random_uuid" "instance_id" {
  count = var.vm_count
}

output "vm_ips" {
  value = {
    for idx, vm in vsphere_virtual_machine.vm : vm.name => vm.default_ip_address
  }
  description = "The IP addresses of the created VMs"
}

output "vm_ids" {
  value = {
    for idx, vm in vsphere_virtual_machine.vm : vm.name => vm.id
  }
  description = "The IDs of the created VMs"
}
