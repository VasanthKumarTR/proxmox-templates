###############################################################################
# PACKER VARIABLES
###############################################################################
# This file contains the values for variables used in the Packer template.
# These settings define how the Ubuntu 24.04 template VM will be built.
###############################################################################

###############################################################################
# CLOUD-INIT CONFIGURATION
###############################################################################
# Location of the cloud-init configuration files for automated installation

http_directory = "http" # Directory containing cloud-init files (user-data, meta-data)

###############################################################################
# VIRTUAL MACHINE SETTINGS
###############################################################################
# These settings define the hardware and OS configuration for the template VM

# Basic VM identity
vm_name          = "Ubuntu-2404-Template" # Name of the template VM in vSphere
vm_guest_os_type = "ubuntu64Guest"        # vSphere guest OS identifier for Ubuntu 64-bit

# VM hardware version and firmware
vm_version    = 14     # VM hardware version (14 is compatible with vSphere 6.7+)
vm_firmware   = "efi"  # Using EFI firmware for modern boot support
vm_cdrom_type = "sata" # SATA CD-ROM type for better performance

# VM CPU configuration
vm_cpu_sockets = 1 # Number of CPU sockets
vm_cpu_cores   = 2 # Cores per socket (total 2 vCPUs)

# VM memory configuration
vm_mem_size = 2048 # 2GB RAM allocated to the VM

# VM storage configuration
vm_disk_size       = 20480 # 20GB disk size (in MB)
thin_provision     = true  # Use thin provisioning to save storage space
disk_eagerly_scrub = false # Don't eagerly scrub zeros (faster provisioning)

# VM hardware configuration
vm_disk_controller_type = ["pvscsi"] # Paravirtual SCSI controller (better performance)
vm_network_card         = "vmxnet3"  # VMXNET3 network adapter (better performance)

# VM boot and authentication settings
vm_boot_wait = "10s"    # Wait 10 seconds before sending boot commands
ssh_username = "ubuntu" # Username for SSH access during build
ssh_password = "ubuntu" # Password for SSH access during build

###############################################################################
# ISO CONFIGURATION
###############################################################################
# Details about the installation media used to build the VM

# ISO image information
iso_file          = "ubuntu-24.04.2-live-server-amd64.iso"                                   # Filename of the Ubuntu ISO
iso_checksum      = "d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"       # SHA256 checksum
iso_checksum_type = "sha256"                                                                 # Checksum type (SHA256)
iso_url           = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso" # Download URL
