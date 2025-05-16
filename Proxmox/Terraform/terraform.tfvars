# Proxmox API connection details
proxmox_api_url = "https://192.168.1.95:8006"

# VM settings
vm_name     = "multipurpose"
target_node = "proxmox" # Replace with your Proxmox node name

# VM resources
vm_cores  = 8
vm_memory = 8192 # 8GB RAM

# Storage settings
disk_size    = "100"
disk_storage = "local-lvm"

# Network settings
network_bridge = "vmbr0"

# SSH public keys for cloud-init
ssh_public_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCb7fcDZfIG+SxuP5UsZaoHPdh9MNxtEL5xRI71hzMS5h4SsZiPGEP4shLcF9YxSncdOJpyOJ6OgumNSFWj2pCd/kqg9wQzk/E1o+FRMbWX5gX8xMzPig8mmKkW5szhnP+yYYYuGUqvTAKX4ua1mQwL6PipWKYJ1huJhgpGHrvSQ6kuywJ23hw4klcaiZKXVYtvTi8pqZHhE5Kx1237a/6GRwnbGLEp0UR2Q/KPf6yRgZIrCdD+AtOznSBsBhf5vqcfnnwEIC/DOnqcOTahBVtFhOKuPSv3bUikAD4Vw7SIRteMltUVkd/O341fx+diKOBY7a8M6pn81HEZEmGsr7rT sam@SamMac.local"
