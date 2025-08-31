# Proxmox VM Templates

This repository contains Packer templates for creating VM templates in Proxmox VE. These templates automate the creation of standardized virtual machine images for various operating systems.

## 🎯 Current Status

| Template | Status | Notes |
|----------|--------|-------|
| Windows Server 2022 | 🧪 **Ready for Testing** | Primary focus - implementation complete |
| Ubuntu 24.04 | ✅ **Working** | Reference implementation (not testing focus) |
| RHEL 7 | 🚧 **Planned** | Next development priority |
| Windows Server 2019 | 🚧 **Planned** | Similar to 2022 implementation |

## 🚀 Quick Start

### For Airgapped Environments
```bash
# Create deployment package
./create-package.sh

# Transfer the generated tar.gz to your Proxmox environment
# Follow QUICK_START.md in the package
```

### For Connected Environments
```bash
# Run preflight check
./preflight-check.sh

# Test Windows 2022 template (primary focus)
cd Proxmox/Windows2022/Packer
./build.sh
```

## 📖 Documentation

- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Comprehensive testing instructions
- **[preflight-check.sh](preflight-check.sh)** - Environment readiness verification
- **[create-package.sh](create-package.sh)** - Airgapped deployment package creation

## 🔧 Prerequisites

### Software
- **Packer** v1.12.0 or later
- **Proxmox VE** 8.4.0 or later
- Network connectivity between build system and Proxmox

### ISO Files Required
- Windows Server 2022 ISO
- VirtIO drivers ISO (`virtio-win-0.1.248.iso`)

See `DOWNLOAD_REQUIREMENTS.md` (created by package script) for download links.

## 🏗️ Template Features

### Ubuntu 24.04
- Cloud-init ready
- Docker and container runtime
- SSH key authentication
- Automatic updates
- Common development tools

### Windows Server 2022
- UEFI boot with TPM support
- VirtIO drivers for optimal performance
- Automated Windows updates
- WinRM configuration for remote management
- Pre-installed software (Chrome, Firefox, 7-Zip, etc.)
- IIS and Container features enabled

## 🧪 Testing Workflow

1. **Environment Setup**: Run `./preflight-check.sh` or `.\preflight-check.ps1`
2. **Focus on Windows 2022**: Primary testing target
3. **Feedback Collection**: Document results and issues
4. **Iteration**: Submit feedback for improvements

## 📁 Repository Structure

```
proxmox-templates/
├── Proxmox/
│   ├── Ubuntu24/
│   │   ├── Packer/          # Ubuntu 24.04 Packer templates
│   │   └── Terraform/       # Terraform modules for Ubuntu VMs
│   └── Windows2022/
│       ├── Packer/          # Windows Server 2022 Packer templates
│       └── Terraform/       # Terraform modules for Windows VMs
├── TESTING_GUIDE.md         # Comprehensive testing guide
├── preflight-check.sh       # Environment readiness check
└── create-package.sh        # Airgapped deployment preparation
```

## 🔐 Security Notes

- Change default passwords in production deployments
- Review and implement organizational security policies
- Test templates in isolated environments first
- Sensitive configuration is stored in `secrets.pkrvars.hcl` files

## 🤝 Contributing

When testing or contributing:

1. Use the preflight check to verify your environment
2. Test baseline templates first (Ubuntu 24.04)
3. Document all issues with complete error messages
4. Share feedback with logs (sensitive data removed)
5. Suggest improvements or customizations

## 📋 Feedback Collection

For effective feedback, please include:
- ✅/❌ Build success status
- ⏱️ Build completion times
- 📝 Complete error messages and logs
- 🔧 Environment details (Proxmox version, network setup)
- 💡 Suggested improvements

## 🔄 Next Development Priorities

Based on testing feedback:
1. Address any Windows 2022 issues identified
2. Implement RHEL 7 template
3. Create Windows 2019 template
4. Add additional customization options
5. Enhance Terraform modules

## 📞 Support

Share your testing results and feedback to help improve the templates for everyone!
