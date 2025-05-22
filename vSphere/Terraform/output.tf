output "ip_addresses" {
  description = "IP addresses of all created virtual machines"
  value = {
    for k, v in vsphere_virtual_machine.vm : k => v.guest_ip_addresses[0]
  }
}

output "vm_names" {
  description = "Names of all created virtual machines"
  value = {
    for k, v in vsphere_virtual_machine.vm : k => v.name
  }
}
