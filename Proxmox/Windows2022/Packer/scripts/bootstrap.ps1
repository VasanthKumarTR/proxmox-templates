# Bootstrap Script for Windows Server 2022 Template
# This script runs during the Windows PE phase to prepare the system

Write-Host "Starting Windows 2022 Template Bootstrap Process..."

# Set timezone to UTC
Write-Host "Setting timezone to UTC..."
tzutil /s "UTC"

# Disable Windows Firewall for all profiles during setup
Write-Host "Disabling Windows Firewall temporarily for setup..."
netsh advfirewall set allprofiles state off

# Enable Remote Desktop
Write-Host "Enabling Remote Desktop..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Set network profile to Private
Write-Host "Setting network profile to Private..."
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

# Disable IE Enhanced Security Configuration
Write-Host "Disabling IE Enhanced Security Configuration..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0

# Enable PowerShell remoting
Write-Host "Enabling PowerShell remoting..."
Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Create temp directory
New-Item -ItemType Directory -Path "C:\temp" -Force

Write-Host "Bootstrap process completed!"
