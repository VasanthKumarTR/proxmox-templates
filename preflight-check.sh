#!/bin/bash
# Proxmox Build Preflight Check

set -e

echo "🔍 Proxmox Build Preflight Check"
echo "================================"

# Check if required variables are set
if [ -z "$PROXMOX_URL" ] || [ -z "$PROXMOX_TOKEN" ] || [ -z "$PROXMOX_NODE" ]; then
    echo "❌ Missing environment variables. Please set:"
    echo "   PROXMOX_URL, PROXMOX_TOKEN, PROXMOX_NODE"
    exit 1
fi

echo "✅ Environment variables set"

# Check Proxmox API connectivity
echo "🌐 Testing Proxmox API connectivity..."
if curl -k -f -s -H "Authorization: PVEAPIToken=$PROXMOX_TOKEN" \
   "$PROXMOX_URL/version" > /dev/null; then
    echo "✅ Proxmox API accessible"
else
    echo "❌ Cannot connect to Proxmox API"
    exit 1
fi

# Check if VM ID 9100 already exists
echo "🔍 Checking if VM ID 9100 exists..."
VM_EXISTS=$(curl -k -s -H "Authorization: PVEAPIToken=$PROXMOX_TOKEN" \
    "$PROXMOX_URL/nodes/$PROXMOX_NODE/qemu/9100" | jq -r '.data // empty')

if [ -n "$VM_EXISTS" ]; then
    echo "⚠️  VM ID 9100 already exists. Use force_rebuild=true to overwrite"
else
    echo "✅ VM ID 9100 available"
fi

# Check required ISOs
echo "📀 Checking required ISOs..."
ISOS=$(curl -k -s -H "Authorization: PVEAPIToken=$PROXMOX_TOKEN" \
    "$PROXMOX_URL/nodes/$PROXMOX_NODE/storage/local/content" | \
    jq -r '.data[] | select(.content=="iso") | .volid')

if echo "$ISOS" | grep -q "en-us_windows_server_2022"; then
    echo "✅ Windows Server 2022 ISO found"
else
    echo "❌ Windows Server 2022 ISO missing"
    echo "   Upload: en-us_windows_server_2022_updated_jan_2024_x64_dvd_2b7a0c9f.iso"
fi

if echo "$ISOS" | grep -q "virtio-win"; then
    echo "✅ VirtIO drivers ISO found"
else
    echo "❌ VirtIO drivers ISO missing"
    echo "   Upload: virtio-win-0.1.248.iso"
fi

echo ""
echo "🎯 Ready to build! Trigger via GitHub Actions or run locally."
