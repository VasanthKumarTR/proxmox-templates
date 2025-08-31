#!/bin/bash

# GitHub Self-Hosted Runner Setup for Proxmox Templates
# This script sets up a self-hosted runner for building Proxmox VM templates

set -e

echo "🚀 Setting up GitHub Self-Hosted Runner for Proxmox Templates"
echo "============================================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please do not run this script as root"
    echo "   Run as a regular user with sudo privileges"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Docker if not present
if ! command_exists docker; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed successfully"
else
    echo "✅ Docker is already installed"
fi

# Check Docker version
echo "🐳 Docker version:"
docker --version

# Pull required Docker images
echo "📥 Pulling required Docker images..."
docker pull hashicorp/packer:1.12.0
docker pull hashicorp/terraform:1.9.0
echo "✅ Docker images pulled successfully"

# Test Docker access
if ! docker ps >/dev/null 2>&1; then
    echo "⚠️  Docker daemon is not running or user doesn't have access"
    echo "   Please ensure Docker is running and user is in docker group"
    echo "   You may need to log out and back in for group changes to take effect"
fi

# Create runner directory
RUNNER_DIR="$HOME/github-runner"
if [ ! -d "$RUNNER_DIR" ]; then
    echo "📁 Creating runner directory: $RUNNER_DIR"
    mkdir -p "$RUNNER_DIR"
fi

# Download GitHub runner (latest version)
echo "📥 Downloading GitHub Actions runner..."
cd "$RUNNER_DIR"

# Get latest runner version
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
echo "   Latest runner version: $RUNNER_VERSION"

# Download runner
RUNNER_FILE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
if [ ! -f "$RUNNER_FILE" ]; then
    curl -o "$RUNNER_FILE" -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_FILE}"
    echo "✅ Runner downloaded successfully"
else
    echo "✅ Runner already downloaded"
fi

# Extract runner
if [ ! -f "run.sh" ]; then
    echo "📦 Extracting runner..."
    tar xzf "$RUNNER_FILE"
    echo "✅ Runner extracted successfully"
else
    echo "✅ Runner already extracted"
fi

# Set up runner as service (optional)
echo ""
echo "🔧 Runner Setup Complete!"
echo "========================"
echo ""
echo "Next steps:"
echo "1. Configure the runner:"
echo "   cd $RUNNER_DIR"
echo "   ./config.sh --url https://github.com/OWNER/REPO --token YOUR_TOKEN"
echo ""
echo "2. Start the runner:"
echo "   ./run.sh"
echo ""
echo "3. (Optional) Install as service:"
echo "   sudo ./svc.sh install"
echo "   sudo ./svc.sh start"
echo ""
echo "💡 Tips:"
echo "- Get your token from: GitHub repo > Settings > Actions > Runners > New runner"
echo "- Use a descriptive runner name like 'proxmox-builder'"
echo "- Add labels like 'proxmox', 'docker', 'self-hosted'"
echo ""
echo "🔐 Required GitHub Secrets:"
echo "- PROXMOX_URL"
echo "- PROXMOX_USERNAME" 
echo "- PROXMOX_TOKEN"
echo "- PROXMOX_NODE"
echo ""

# Test Proxmox connectivity (if variables provided)
if [ ! -z "$PROXMOX_URL" ] && [ ! -z "$PROXMOX_TOKEN" ]; then
    echo "🔍 Testing Proxmox connectivity..."
    # Simple curl test (would need proper implementation)
    echo "   (Manual test required - see GitHub secrets configuration)"
fi

echo "✅ Setup complete! Follow the next steps above to configure your runner."
