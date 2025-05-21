##################################################################################
# VARIABLES
##################################################################################

# HTTP Settings

http_directory = "http"

# Virtual Machine Settings

vm_name                     = "Ubuntu-2404-Template"
vm_guest_os_type            = "ubuntu64Guest"
vm_version                  = 14
vm_firmware                 = "efi"
vm_cdrom_type               = "sata"
vm_cpu_sockets              = 1
vm_cpu_cores                = 2
vm_mem_size                 = 2048
vm_disk_size                = 20480
thin_provision              = true
disk_eagerly_scrub          = false
vm_disk_controller_type     = ["pvscsi"]
vm_network_card             = "vmxnet3"
vm_boot_wait                = "10s"
ssh_username                = "ubuntu"
ssh_password                = "ubuntu"

# ISO Objects

iso_file                    = "ubuntu-24.04.2-live-server-amd64.iso"
iso_checksum                = "d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
iso_checksum_type           = "sha256"
iso_url                     = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
