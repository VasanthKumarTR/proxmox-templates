# Quick Start Guide for Windows Server Environments

## Prerequisites for Windows Server

### 1. Install Packer
```powershell
# OPTION A: Automatic Installation (if internet available)
.\Install-Packer.ps1

# OPTION B: Manual Installation
# Download Packer for Windows
# URL: https://releases.hashicorp.com/packer/1.12.0/packer_1.12.0_windows_amd64.zip
# Extract packer.exe to C:\Tools\Packer\
# Add C:\Tools\Packer to your PATH environment variable

# OPTION C: Quick Manual Setup
New-Item -ItemType Directory -Path "C:\Tools\Packer" -Force
# Extract downloaded zip to C:\Tools\Packer\
$env:PATH += ";C:\Tools\Packer"  # For current session
# For permanent: Add via System Properties > Environment Variables

# Verify installation
packer version
```

### 2. Set PowerShell Execution Policy
```powershell
# Allow script execution (run as Administrator if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify the policy
Get-ExecutionPolicy
```

### 3. Verify Environment
```powershell
# Run the PowerShell preflight check
.\preflight-check.ps1
```

## Quick Testing Steps

### Step 1: Setup Repository (5 minutes)
```powershell
# Extract the repository package
# Assuming you've transferred the tar.gz file, extract it using 7-Zip or similar

# Navigate to the repository
cd C:\path\to\proxmox-templates

# Install Packer if needed
.\Install-Packer.ps1

# Run preflight check
.\preflight-check.ps1
```

### Step 2: Configure Secrets (2 minutes)
```powershell
# Windows 2022 template
cd Proxmox\Windows2022\Packer
Copy-Item secrets.pkrvars.hcl.example secrets.pkrvars.hcl
# Edit secrets.pkrvars.hcl with your Proxmox credentials

# Go back to root
cd ..\..\..
```

### Step 3: Fix ISO Creation Tools (if needed)
```powershell
# If you get "could not find a supported CD ISO creation command" error
.\Fix-ISO-Creation.ps1 -CheckOnly

# Install Windows ADK (recommended - includes oscdimg.exe)
.\Fix-ISO-Creation.ps1 -InstallADK

# Or install just oscdimg.exe (lightweight option)
.\Fix-ISO-Creation.ps1 -UseOSCDIMG
```

### Step 4: Test Windows 2022 Template (2-4 hours)
```powershell
# Use the unified build script
.\Build-Template.ps1

# Or use the individual script
cd Proxmox\Windows2022\Packer
.\build.ps1
```

## PowerShell Script Options

### Unified Build Script
```powershell
# Basic usage (defaults to Windows2022)
.\Build-Template.ps1

# Force rebuild (overwrites existing template)
.\Build-Template.ps1 -Force

# Validate only (don't build)
.\Build-Template.ps1 -Validate

# Show help
.\Build-Template.ps1 -Help
```

### Individual Build Scripts
```powershell
# In each Packer directory
.\build.ps1              # Normal build
.\build.ps1 -Force       # Force rebuild
.\build.ps1 -Validate    # Validate only
.\build.ps1 -Help        # Show help
```

## Windows-Specific Notes

### PowerShell vs Command Prompt
- Use **PowerShell** (not Command Prompt) for all operations
- PowerShell ISE or VS Code work well for editing scripts
- Windows Terminal provides a better experience than legacy console

### File Paths
- Use backslashes (`\`) for Windows paths in configuration files
- PowerShell handles both forward and back slashes in most cases
- Be careful with escaping in JSON/HCL files

### Antivirus Considerations
- Packer may trigger antivirus software during builds
- Consider adding Packer and the working directory to AV exclusions
- Monitor AV logs if builds fail unexpectedly

### Network Connectivity
- Ensure Windows Firewall allows Packer to communicate with Proxmox
- Check corporate proxy settings if builds fail to download updates
- WinRM ports (5985/5986) must be accessible from build machine to VMs

## Troubleshooting Windows-Specific Issues

### PowerShell Execution Policy
```powershell
# If scripts won't run
Get-ExecutionPolicy -List

# Fix restrictive policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Path Issues
```powershell
# Check if Packer is in PATH
Get-Command packer

# Add Packer to PATH for current session
$env:PATH += ";C:\Tools\Packer"

# Add permanently through System Properties > Environment Variables
```

### ISO Creation Tools Missing
```powershell
# Error: "could not find a supported CD ISO creation command"
# Fix: Install Windows ADK or oscdimg.exe

# Check what tools are available
.\Fix-ISO-Creation.ps1 -CheckOnly

# Install Windows ADK (contains oscdimg.exe)
.\Fix-ISO-Creation.ps1 -InstallADK

# After installation, restart PowerShell and retry build
```

### Long Path Support
```powershell
# Enable long path support (Windows 10/Server 2016+)
# Run as Administrator
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

### SSL/TLS Issues
```powershell
# If encountering SSL issues with downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

## File Extraction on Windows

If you receive a `.tar.gz` file:

### Using 7-Zip (Recommended)
1. Install 7-Zip from https://www.7-zip.org/
2. Right-click the `.tar.gz` file
3. Choose "7-Zip" > "Extract Here"
4. Extract the resulting `.tar` file the same way

### Using PowerShell (Windows 10/Server 2019+)
```powershell
# For .zip files (if available)
Expand-Archive -Path "proxmox-templates.zip" -DestinationPath "C:\proxmox-templates"

# For .tar.gz files, use tar command (Windows 10/Server 2019+)
tar -xzf proxmox-templates.tar.gz
```

### Using Windows Subsystem for Linux (WSL)
```bash
# If WSL is available
tar -xzf proxmox-templates.tar.gz
```

## Testing Checklist

- [ ] PowerShell execution policy configured
- [ ] Packer installed and in PATH
- [ ] Repository extracted and accessible
- [ ] Secrets files configured with actual credentials
- [ ] Windows Server 2022 ISO uploaded to Proxmox
- [ ] VirtIO drivers ISO uploaded to Proxmox
- [ ] Network connectivity to Proxmox verified
- [ ] Windows 2022 template build started
- [ ] Build logs collected for feedback

## Performance Tips

- Run builds on SSD storage for better performance
- Ensure adequate RAM (8GB+ recommended for Windows builds)
- Close unnecessary applications during builds
- Monitor disk space (Windows builds can use significant temporary space)
- Use a wired network connection for reliability

## Next Steps After Successful Builds

1. **Test Template Deployment**: Create VMs from the Windows template in Proxmox
2. **Verify Functionality**: Test all installed software and features
3. **Document Issues**: Note any problems for feedback
4. **Plan RHEL 7**: Prepare for the next template development phase
5. **Consider Windows 2019**: Similar to 2022 but may need specific adjustments
