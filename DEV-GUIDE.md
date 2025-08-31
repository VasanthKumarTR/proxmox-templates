# Development Guide

## Architecture Overview

This repository uses a containerized CI/CD approach with GitHub Actions to build Proxmox VM templates. All builds run in Docker containers on self-hosted runners, eliminating platform-specific dependencies.

## Development Workflow

### 1. Local Development

```bash
# Clone and setup
git clone https://github.com/yourusername/proxmox-templates.git
cd proxmox-templates

# Create feature branch
git checkout -b feature/new-template

# Edit templates locally
code Proxmox/Ubuntu24/Packer/ubuntu-2404.pkr.hcl
```

### 2. Local Validation (Optional)

```bash
# Validate Ubuntu template
docker run --rm -v $PWD:/workspace -w /workspace/Proxmox/Ubuntu24/Packer \
  hashicorp/packer:1.12.0 validate -var-file=variables.pkrvars.hcl ubuntu-2404.pkr.hcl

# Validate Windows template
docker run --rm -v $PWD:/workspace -w /workspace/Proxmox/Windows2022/Packer \
  hashicorp/packer:1.12.0 validate -var-file=variables.pkrvars.hcl windows-2022.pkr.hcl
```

### 3. Push and Test

```bash
# Commit changes
git add -A
git commit -m "feat: update ubuntu template configuration"

# Push to trigger validation
git push origin feature/new-template
```

### 4. Production Build

```bash
# Merge to main triggers production build
git checkout main
git merge feature/new-template
git push origin main
```

## Repository Structure

```
proxmox-templates/
├── .github/workflows/
│   └── build-templates.yml     # Main CI/CD workflow
├── Proxmox/
│   ├── Ubuntu24/
│   │   ├── Packer/
│   │   │   ├── ubuntu-2404.pkr.hcl
│   │   │   ├── variables.pkrvars.hcl
│   │   │   ├── secrets.pkrvars.hcl.example
│   │   │   └── http/
│   │   │       ├── meta-data
│   │   │       └── user-data
│   │   └── Terraform/
│   │       ├── main.tf
│   │       └── variables.tf
│   ├── Windows2022/
│   │   ├── Packer/
│   │   │   ├── windows-2022.pkr.hcl
│   │   │   ├── variables.pkrvars.hcl
│   │   │   ├── secrets.pkrvars.hcl.example
│   │   │   ├── answer_files/
│   │   │   │   └── autounattend.xml
│   │   │   └── scripts/
│   │   │       ├── bootstrap.ps1
│   │   │       ├── install-updates.ps1
│   │   │       └── setup-winrm.ps1
│   │   └── Terraform/
│   │       ├── main.tf
│   │       └── variables.tf
│   └── RHEL7/ (planned)
├── README.md
└── DEV-GUIDE.md
```

## CI/CD Pipeline

### Trigger Conditions

**Automatic Triggers:**
- Push to `main` branch
- Pull requests to `main`
- Changes to `Proxmox/` directory
- Changes to `.github/workflows/`

**Manual Triggers:**
- GitHub Actions UI > "Run workflow"
- API calls or webhooks

### Pipeline Stages

1. **Validate** - Syntax check all templates
2. **Build** - Create VM templates with Packer
3. **Test** - Deploy test VMs with Terraform (optional)
4. **Notify** - Report build status

### Build Matrix

Templates are built in parallel with failure isolation:
- `ubuntu2404` - Ubuntu 24.04 LTS
- `windows2022` - Windows Server 2022
- `rhel7` - RHEL 7 (when available)

## Self-Hosted Runner Setup

### Requirements

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install GitHub runner
# Follow: https://docs.github.com/en/actions/hosting-your-own-runners
```

### Runner Configuration

The runner must have:
- **Docker** installed and running
- **Network access** to Proxmox API
- **Sufficient resources** for builds (4+ CPU, 8GB+ RAM)
- **Storage space** for Docker images and build artifacts

### Security Considerations

- Use dedicated runner for security isolation
- Limit runner permissions to minimum required
- Monitor runner logs and resource usage
- Regularly update runner software

## GitHub Secrets Configuration

### Required Secrets

```bash
# Proxmox API credentials
PROXMOX_URL=https://proxmox.example.com:8006/api2/json
PROXMOX_USERNAME=root@pam!terraform
PROXMOX_TOKEN=your-generated-api-token
PROXMOX_NODE=proxmox-node-name
```

### Secret Management

1. **Repository Settings** > Secrets and variables > Actions
2. **Add secret** for each required variable
3. **Test connectivity** with a simple workflow run

## Template Development

### Adding New Templates

1. **Create directory structure:**
   ```bash
   mkdir -p Proxmox/NewOS/Packer
   mkdir -p Proxmox/NewOS/Terraform
   ```

2. **Create Packer template:**
   ```hcl
   # Proxmox/NewOS/Packer/newos.pkr.hcl
   packer {
     required_plugins {
       proxmox = {
         version = ">= 1.1.3"
         source  = "github.com/hashicorp/proxmox"
       }
     }
   }
   # ... template configuration
   ```

3. **Update CI/CD workflow:**
   ```yaml
   # Add to .github/workflows/build-templates.yml
   # in the template detection logic
   ```

### Template Best Practices

- **Use variables** for all configurable options
- **Implement secrets management** for sensitive data
- **Add validation** for all input parameters
- **Document configuration** in README files
- **Test thoroughly** before merging

### Variable Management

**Public variables** (`variables.pkrvars.hcl`):
```hcl
# ISO files and storage
iso_file = "local:iso/ubuntu-24.04-live-server-amd64.iso"
iso_storage_pool = "local"

# VM specifications
vm_id = "9000"
cores = "2"
memory = "2048"
```

**Secret variables** (`secrets.pkrvars.hcl`):
```hcl
# Proxmox API
proxmox_url = "https://proxmox.example.com:8006/api2/json"
proxmox_username = "root@pam!terraform"
proxmox_token = "your-api-token"
proxmox_node = "proxmox-node"
```

## Debugging and Troubleshooting

### GitHub Actions Debugging

```yaml
# Add debug steps to workflow
- name: Debug Environment
  run: |
    echo "Current directory: $(pwd)"
    echo "Available files:"
    ls -la
    echo "Docker version:"
    docker --version
```

### Local Testing

```bash
# Test Packer template locally
cd Proxmox/Ubuntu24/Packer
cp secrets.pkrvars.hcl.example secrets.pkrvars.hcl
# Edit secrets.pkrvars.hcl

# Validate template
docker run --rm -v $PWD:/workspace -w /workspace \
  hashicorp/packer:1.12.0 validate \
  -var-file=variables.pkrvars.hcl \
  -var-file=secrets.pkrvars.hcl \
  ubuntu-2404.pkr.hcl
```

### Common Issues

**Build Timeout:**
- Increase timeout in workflow
- Check Proxmox resource availability
- Verify network connectivity

**Permission Errors:**
- Check Proxmox API token permissions
- Verify runner has Docker access
- Review GitHub secrets configuration

**Template Validation Errors:**
- Check syntax with local validation
- Verify variable references
- Review Packer logs for details

## Performance Optimization

### Build Performance

- **Sequential builds** prevent resource conflicts
- **Docker layer caching** speeds up builds
- **Artifact cleanup** maintains disk space
- **Build artifacts** uploaded for debugging

### Resource Management

- Monitor runner CPU/memory usage
- Clean up old Docker images regularly
- Archive old build logs and artifacts
- Scale runners based on build frequency

## Monitoring and Maintenance

### Build Monitoring

- **GitHub Actions** provides build status and logs
- **Email notifications** for failed builds
- **Slack/Teams integration** for team alerts
- **Custom dashboards** for build metrics

### Regular Maintenance

- **Update Docker images** monthly
- **Review and rotate secrets** quarterly
- **Update templates** for security patches
- **Test disaster recovery** procedures

## Contributing Guidelines

### Code Standards

- Use consistent naming conventions
- Document all variables and options
- Include examples and usage instructions
- Test all changes thoroughly

### Pull Request Process

1. **Create feature branch** from main
2. **Make changes** with descriptive commits
3. **Test locally** if possible
4. **Create pull request** with detailed description
5. **Address review feedback** promptly
6. **Merge after approval** and successful builds

### Review Checklist

- [ ] Template syntax is valid
- [ ] Variables are properly defined
- [ ] Documentation is updated
- [ ] CI/CD pipeline passes
- [ ] Security considerations addressed

---

For questions or issues, check the repository issues or create a new one with detailed information about the problem.
