proxmox_url      = "https://192.168.1.95:8006/api2/json"
proxmox_username = "root@pam!terraform"
# Leave token empty here, provide it in secrets.pkrvars.hcl
vm_id            = "9100"
iso_file         = "local:iso/en-us_windows_server_2022_updated_jan_2024_x64_dvd_2b7a0c9f.iso"
virtio_iso_file  = "local:iso/virtio-win-0.1.248.iso"
winrm_username   = "Administrator"
proxmox_node     = "proxmox"
