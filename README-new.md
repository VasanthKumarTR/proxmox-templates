# Proxmox VM Templates

Automated VM template creation for Proxmox VE using Packer and Terraform, with GitHub Actions CI/CD.

## 🚀 Quick Start

1. **Fork this repository** to your GitHub account
2. **Setup GitHub Secrets** with your Proxmox credentials
3. **Configure a self-hosted runner** on a machine with Proxmox access
4. **Push changes or trigger builds** via GitHub Actions

## 📋 Available Templates

| Template | OS | Status | VM ID |
|----------|----|---------|----|
| Ubuntu 24.04 LTS | Ubuntu Server 24.04 | ✅ Ready | 9000 |
| Windows Server 2022 | Windows Server 2022 Standard | ✅ Ready | 9100 |
| RHEL 7 | Red Hat Enterprise Linux 7 | 🚧 In Progress | 9200 |

## ⚙️ Setup

### GitHub Secrets

Configure these secrets in your GitHub repository:

```
PROXMOX_URL=https://your-proxmox:8006/api2/json
PROXMOX_USERNAME=root@pam!terraform
PROXMOX_TOKEN=your-api-token
PROXMOX_NODE=your-node-name
```

### Self-Hosted Runner

1. **Install Docker** on your runner machine
2. **Setup GitHub runner** following [GitHub's guide](https://docs.github.com/en/actions/hosting-your-own-runners)
3. **Ensure network access** to your Proxmox cluster

## 🏗️ Building Templates

### Automatic Builds

Templates are automatically built when:
- Changes are pushed to `main` branch
- Pull requests are created
- Files in `Proxmox/` directory are modified

### Manual Builds

Trigger builds manually via GitHub Actions:

1. Go to **Actions** tab in your repository
2. Select **Build Proxmox Templates** workflow
3. Click **Run workflow**
4. Choose template and options

### Build Options

- **Template**: Choose specific template or "all"
- **Force Rebuild**: Overwrite existing templates
- **Terraform Apply**: Test template deployment after build

## 🔧 Development

### Local Development

```bash
# Clone repository
git clone https://github.com/yourusername/proxmox-templates.git
cd proxmox-templates

# Validate templates (requires Docker)
docker run --rm -v $PWD:/workspace -w /workspace/Proxmox/Ubuntu24/Packer \
  hashicorp/packer:1.12.0 validate -var-file=variables.pkrvars.hcl ubuntu-2404.pkr.hcl
```

### Template Structure

```
Proxmox/
├── Ubuntu24/
│   ├── Packer/
│   │   ├── ubuntu-2404.pkr.hcl      # Packer template
│   │   ├── variables.pkrvars.hcl     # Template variables
│   │   ├── secrets.pkrvars.hcl.example
│   │   └── http/                     # Cloud-init files
│   └── Terraform/
│       ├── main.tf                   # Terraform deployment
│       └── variables.tf
├── Windows2022/
│   ├── Packer/
│   │   ├── windows-2022.pkr.hcl
│   │   ├── answer_files/
│   │   └── scripts/
│   └── Terraform/
└── RHEL7/ (coming soon)
```

### Workflow

1. **Edit templates** locally or via GitHub web interface
2. **Commit changes** to a feature branch
3. **Create pull request** to trigger validation
4. **Merge to main** to trigger production builds
5. **Monitor builds** in GitHub Actions

## 📊 Monitoring

### Build Status

- ✅ **Success**: Template built and ready for use
- ❌ **Failed**: Check logs in GitHub Actions
- 🟡 **Running**: Build in progress

### Logs and Artifacts

- **Build logs**: Available in GitHub Actions runs
- **Packer cache**: Uploaded as artifacts for debugging
- **Terraform plans**: Generated during test phase

## 🛠️ Troubleshooting

### Common Issues

**Build Fails - Network**
- Ensure runner has access to Proxmox
- Check firewall rules for API access

**Build Fails - Resources**
- Verify Proxmox node has sufficient CPU/RAM
- Check storage space for ISO files and templates

**Template Not Found**
- Ensure ISO files are uploaded to Proxmox
- Check storage pool names in variables

### Getting Help

1. **Check GitHub Actions logs** for detailed error messages
2. **Review Packer documentation** for template syntax
3. **Verify Proxmox API connectivity** from runner

## 🎯 Roadmap

- [x] Ubuntu 24.04 LTS template
- [x] Windows Server 2022 template
- [x] GitHub Actions CI/CD
- [x] Containerized builds
- [ ] RHEL 7 template
- [ ] Windows Server 2019 template
- [ ] Multi-architecture support (ARM64)
- [ ] Template versioning and rollback
- [ ] Integration tests with Ansible

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with GitHub Actions
5. Submit a pull request

---

**Built with ❤️ using Packer, Terraform, and GitHub Actions**
