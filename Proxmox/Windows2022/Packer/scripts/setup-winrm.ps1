# Setup WinRM for Packer communication
# This script configures WinRM to allow Packer to connect

Write-Host "Configuring WinRM for Packer..."

# Configure WinRM service
Write-Host "Starting WinRM service..."
Start-Service WinRM
Set-Service WinRM -StartupType Automatic

# Configure WinRM to allow unencrypted traffic and basic authentication
Write-Host "Configuring WinRM settings..."
winrm quickconfig -q
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'

# Configure firewall for WinRM
Write-Host "Configuring firewall for WinRM..."
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

# Restart WinRM service
Write-Host "Restarting WinRM service..."
Restart-Service WinRM

Write-Host "WinRM configuration completed!"

# Test WinRM connectivity
Write-Host "Testing WinRM connectivity..."
Test-WSMan -ComputerName localhost
