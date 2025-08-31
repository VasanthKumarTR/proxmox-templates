#!/bin/bash
# Discover Proxmox Node Names

echo "🔍 Discovering Proxmox Node Names"
echo "================================="

if [ -z "$1" ]; then
    echo "Usage: $0 <proxmox-ip-or-hostname>"
    echo "Example: $0 192.168.1.95"
    echo "Example: $0 proxmox.local"
    exit 1
fi

PROXMOX_HOST="$1"
PROXMOX_URL="https://${PROXMOX_HOST}:8006/api2/json"

echo "🌐 Connecting to: $PROXMOX_URL"
echo ""

# Method 1: No authentication (public endpoint)
echo "📋 Available Nodes (no auth required):"
curl -k -s "$PROXMOX_URL/nodes" | jq -r '.data[]?.node // "No nodes found or auth required"' 2>/dev/null || echo "❌ Could not fetch without authentication"

echo ""
echo "💡 If you see node names above, use one of them as PROXMOX_NODE"
echo ""
echo "🔐 To get detailed info, you need authentication:"
echo "   1. Create API token in Proxmox UI: Datacenter → Permissions → API Tokens"
echo "   2. Run: curl -k -H 'Authorization: PVEAPIToken=root@pam!terraform=YOUR_SECRET' '$PROXMOX_URL/nodes'"
echo ""
echo "🎯 Common node names:"
echo "   - proxmox (default)"
echo "   - pve"
echo "   - proxmox1, proxmox2, etc."
echo "   - Your custom hostname"
