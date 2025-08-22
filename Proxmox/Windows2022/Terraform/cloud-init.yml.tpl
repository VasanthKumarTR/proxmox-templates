#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

# Network configuration
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - ${ip_address}/24
      gateway4: ${gateway}
      nameservers:
        addresses: [${join(", ", dns_servers)}]
        search: [${domain}]

# Windows-specific configuration
timezone: UTC

# Run commands on first boot
runcmd:
  - powershell.exe -Command "Rename-Computer -NewName '${hostname}' -Force"
  - powershell.exe -Command "Set-TimeZone -Id 'UTC'"
  - powershell.exe -Command "New-NetFirewallRule -DisplayName 'Allow RDP' -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow"
  - powershell.exe -Command "Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name 'fDenyTSConnections' -value 0"
  - powershell.exe -Command "Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'"

# Final reboot
power_state:
  delay: 30
  mode: reboot
  message: "Rebooting after cloud-init setup"
