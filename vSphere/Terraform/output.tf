###############################################################################
# TERRAFORM OUTPUTS
###############################################################################
# Output values are the return values of a Terraform module that can be used
# by other modules or displayed to the user when Terraform applies.
# These outputs provide valuable information about the created resources.
###############################################################################

# Map of IP addresses for all created VMs
output "ip_addresses" {
  description = "IP addresses of all created virtual machines"
  # This creates a map where:
  # - The key is the VM key from the for_each (e.g., "vm1", "vm2")
  # - The value is the first IP address assigned to the VM
  value = {
    for k, v in vsphere_virtual_machine.vm : k => v.guest_ip_addresses[0]
  }
  # Example output:
  # ip_addresses = {
  #   "vm1" = "192.168.1.97"
  #   "vm2" = "192.168.1.98"
  # }
}

# Map of VM names for all created VMs
output "vm_names" {
  description = "Names of all created virtual machines"
  # This creates a map where:
  # - The key is the VM key from the for_each (e.g., "vm1", "vm2")
  # - The value is the name assigned to the VM
  value = {
    for k, v in vsphere_virtual_machine.vm : k => v.name
  }
  # Example output:
  # vm_names = {
  #   "vm1" = "ubuntu24-04-vm1"
  #   "vm2" = "ubuntu24-04-vm2"
  # }
}
