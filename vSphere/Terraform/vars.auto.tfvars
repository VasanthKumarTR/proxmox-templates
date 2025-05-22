cpu                    = 1
cores-per-socket       = 1
ram                    = 2048
disksize               = 40 # in GB
vm-guest-id            = "ubuntu64Guest"
vsphere-unverified-ssl = "true"
vsphere-datacenter     = "Datacenter"
vsphere-cluster        = "Cluster01"
vm-datastore           = "Datastore2_NonSSD"
vm-network             = "VM Network"
vm-domain              = "home"
dns_server_list        = ["8.8.8.8", "8.8.4.4"]
ipv4_gateway           = "192.168.1.254"
ipv4_netmask           = "24"
vm-template-name       = "Ubuntu-2404-Template"

# Note: The specific VM names and IP addresses are defined in the locals block 
# in variables.tf using the for_each configuration
