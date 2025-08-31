# Fix ISO Creation Tools for Packer on Windows Server
# This script installs the necessary tools for Packer to create ISO files

param(
    [switch]$InstallADK,
    [switch]$UseOSCDIMG,
    [switch]$CheckOnly,
    [switch]$Help
)

function Write-StatusMessage {
    param([string]$Message, [string]$Type = "Info")
    
    $color = switch ($Type) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        "Step" { "Cyan" }
        default { "White" }
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Test-ISOCreationTools {
    Write-StatusMessage "Checking for ISO creation tools..." "Step"
    
    $tools = @{
        "oscdimg" = $false
        "mkisofs" = $false
        "xorriso" = $false
    }
    
    # Check for oscdimg (Windows ADK)
    try {
        $oscdimg = Get-Command oscdimg -ErrorAction SilentlyContinue
        if ($oscdimg) {
            $tools["oscdimg"] = $true
            Write-StatusMessage "Found oscdimg at: $($oscdimg.Source)" "Success"
        }
    } catch {
        Write-StatusMessage "oscdimg not found" "Warning"
    }
    
    # Check for mkisofs
    try {
        $mkisofs = Get-Command mkisofs -ErrorAction SilentlyContinue
        if ($mkisofs) {
            $tools["mkisofs"] = $true
            Write-StatusMessage "Found mkisofs at: $($mkisofs.Source)" "Success"
        }
    } catch {
        Write-StatusMessage "mkisofs not found" "Warning"
    }
    
    # Check for xorriso
    try {
        $xorriso = Get-Command xorriso -ErrorAction SilentlyContinue
        if ($xorriso) {
            $tools["xorriso"] = $true
            Write-StatusMessage "Found xorriso at: $($xorriso.Source)" "Success"
        }
    } catch {
        Write-StatusMessage "xorriso not found" "Warning"
    }
    
    return $tools
}

function Install-WindowsADK {
    Write-StatusMessage "Installing Windows Assessment and Deployment Kit (ADK)..." "Step"
    Write-StatusMessage "This will install oscdimg.exe which Packer can use" "Info"
    
    $adkUrl = "https://go.microsoft.com/fwlink/?linkid=2271337"
    $downloadPath = "$env:TEMP\adksetup.exe"
    
    try {
        Write-StatusMessage "Downloading Windows ADK installer..." "Step"
        Invoke-WebRequest -Uri $adkUrl -OutFile $downloadPath -UseBasicParsing
        
        Write-StatusMessage "Starting ADK installation..." "Step"
        Write-StatusMessage "IMPORTANT: Only install 'Deployment Tools' feature (contains oscdimg)" "Warning"
        
        Start-Process -FilePath $downloadPath -ArgumentList "/quiet", "/features", "OptionId.DeploymentTools" -Wait
        
        # Update PATH to include ADK tools
        $adkPath = "${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg"
        if (Test-Path $adkPath) {
            $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
            if ($currentPath -notlike "*$adkPath*") {
                [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$adkPath", "Machine")
                $env:PATH += ";$adkPath"
                Write-StatusMessage "Added ADK tools to PATH" "Success"
            }
        }
        
        Write-StatusMessage "Windows ADK installation completed" "Success"
        Remove-Item $downloadPath -Force -ErrorAction SilentlyContinue
        
    } catch {
        Write-StatusMessage "Failed to install Windows ADK: $($_.Exception.Message)" "Error"
        return $false
    }
    
    return $true
}

function Install-OSCDIMGOnly {
    Write-StatusMessage "Installing oscdimg.exe directly..." "Step"
    
    $toolsDir = "C:\Tools\oscdimg"
    New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
    
    # Download oscdimg.exe directly (from Windows SDK)
    $oscdimgUrl = "https://github.com/microsoft/Windows-universal-samples/raw/main/Samples/CameraStarterKit/cs/Tools/oscdimg.exe"
    $oscdimgPath = "$toolsDir\oscdimg.exe"
    
    try {
        Write-StatusMessage "Downloading oscdimg.exe..." "Step"
        Invoke-WebRequest -Uri $oscdimgUrl -OutFile $oscdimgPath -UseBasicParsing
        
        # Add to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$toolsDir*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$toolsDir", "Machine")
            $env:PATH += ";$toolsDir"
        }
        
        Write-StatusMessage "oscdimg.exe installed to: $oscdimgPath" "Success"
        return $true
        
    } catch {
        Write-StatusMessage "Failed to download oscdimg.exe: $($_.Exception.Message)" "Error"
        
        # Alternative: Create manual instructions
        Write-StatusMessage "Creating manual installation instructions..." "Step"
        
        $instructions = @"
Manual oscdimg.exe Installation Instructions:

1. Download Windows ADK from Microsoft:
   https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install

2. Install only the 'Deployment Tools' feature

3. oscdimg.exe will be located at:
   ${env:ProgramFiles(x86)}\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe

4. Add this directory to your PATH environment variable

Alternative: Copy oscdimg.exe from another Windows machine that has Windows SDK installed.
"@
        
        Set-Content -Path "oscdimg-installation-instructions.txt" -Value $instructions
        Write-StatusMessage "Instructions saved to: oscdimg-installation-instructions.txt" "Info"
        return $false
    }
}

# Main execution
if ($Help) {
    Write-Host "Fix ISO Creation Tools for Packer" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "This script fixes the 'could not find a supported CD ISO creation command' error"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -CheckOnly     Only check for existing tools (don't install)"
    Write-Host "  -InstallADK    Install full Windows ADK (recommended)"
    Write-Host "  -UseOSCDIMG    Install oscdimg.exe only (lightweight)"
    Write-Host "  -Help          Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\Fix-ISO-Creation.ps1 -CheckOnly"
    Write-Host "  .\Fix-ISO-Creation.ps1 -InstallADK"
    Write-Host "  .\Fix-ISO-Creation.ps1 -UseOSCDIMG"
    exit 0
}

Write-StatusMessage "=== Packer ISO Creation Tools Fix ===" "Step"

# Check current status
$tools = Test-ISOCreationTools

$hasAnyTool = $tools.Values -contains $true

if ($CheckOnly) {
    if ($hasAnyTool) {
        Write-StatusMessage "ISO creation tools are available. Packer should work." "Success"
    } else {
        Write-StatusMessage "No ISO creation tools found. Run with -InstallADK or -UseOSCDIMG to fix." "Error"
    }
    exit 0
}

if ($hasAnyTool) {
    Write-StatusMessage "ISO creation tools are already available!" "Success"
    Write-StatusMessage "Your Packer build should now work. Try running it again." "Info"
    exit 0
}

# Install tools
if ($InstallADK) {
    $success = Install-WindowsADK
} elseif ($UseOSCDIMG) {
    $success = Install-OSCDIMGOnly
} else {
    Write-StatusMessage "No installation option specified. Use -InstallADK or -UseOSCDIMG" "Error"
    Write-StatusMessage "Run with -Help for more information" "Info"
    exit 1
}

if ($success) {
    Write-StatusMessage "Installation completed successfully!" "Success"
    Write-StatusMessage "Please restart your PowerShell session and try Packer again." "Info"
    Write-StatusMessage ""
    Write-StatusMessage "To test: packer validate -var-file=variables.pkrvars.hcl -var-file=secrets.pkrvars.hcl windows-2022.pkr.hcl" "Info"
} else {
    Write-StatusMessage "Installation failed. Check the error messages above." "Error"
    Write-StatusMessage "You may need to manually install Windows ADK or copy oscdimg.exe from another machine." "Warning"
}
