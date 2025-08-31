proxmox_url      = "https://172.16.11.1:8006/api2/json"
proxmox_username = "root@pam"
# Leave token empty here, provide it in secrets.pkrvars.hcl
vm_id            = "9100"
iso_file         = "local:iso/SERVER_EVAL_x64FRE_en-us.iso"
virtio_iso_file  = "local:iso/virtio-win-0.1.248.iso"
winrm_username   = "Administrator"
proxmox_node     = "aqua"
