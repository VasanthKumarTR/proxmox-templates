# Install Windows Updates
# This script installs all available Windows updates

Write-Host "Installing Windows Updates..."

# Install PSWindowsUpdate module if not present
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Installing PSWindowsUpdate module..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module PSWindowsUpdate -Force
}

# Import the module
Import-Module PSWindowsUpdate

# Install all available updates
Write-Host "Downloading and installing Windows updates..."
try {
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false -Verbose
    Write-Host "Windows updates installed successfully!"
} catch {
    Write-Host "Error installing updates: $($_.Exception.Message)"
    # Continue anyway as some updates might fail but others succeed
}

# Clean up update cache
Write-Host "Cleaning up Windows Update cache..."
Stop-Service wuauserv -Force
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv

Write-Host "Windows Update process completed!"
