# Proxmox Windows Server 2022 Template

Automated Windows Server 2022 template creation for Proxmox VE using Packer (and optional Terraform test), driven by GitHub Actions.

## 🚀 Quick Start

1. **Fork this repository** to your GitHub account
2. **Setup GitHub Secrets** with your Proxmox credentials
3. **Configure a self-hosted runner** on a machine with Proxmox access
4. **Push changes or trigger builds** via GitHub Actions

## 📋 Template

| Template | OS | VM ID |
|----------|----|-------|
| Windows Server 2022 | Windows Server 2022 Standard | 9100 |

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

Trigger builds manually via GitHub Actions (Run workflow) and optionally enable Terraform test or force rebuild.

## 🔧 Development

### Local Validation (Docker)

```bash
git clone https://github.com/yourusername/proxmox-templates.git
cd proxmox-templates/Proxmox/Windows2022/Packer
docker run --rm -v $PWD:/workspace -w /workspace hashicorp/packer:1.12.0 validate -var-file=variables.pkrvars.hcl windows-2022.pkr.hcl
```

### Structure

```
Proxmox/
└── Windows2022/
  ├── Packer/
  │   ├── windows-2022.pkr.hcl
  │   ├── variables.pkrvars.hcl
  │   ├── secrets.pkrvars.hcl.example
  │   ├── answer_files/
  │   └── scripts/
  └── Terraform/
    ├── main.tf
    └── variables.tf
```

### Workflow

1. Edit the Packer template or scripts
2. Commit and push (PRs trigger validation, main builds)
3. Monitor GitHub Actions
4. (Optional) Terraform test deploy

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

## 🎯 Roadmap (Focused)

- [x] Windows Server 2022 template
- [x] GitHub Actions CI/CD
- [x] Containerized builds
- [ ] Terraform output validation enhancements
- [ ] Add health checks & Proxmox API preflight
- [ ] Additional OS templates (future separate branches)

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
