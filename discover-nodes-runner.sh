#!/bin/bash
# Discover Proxmox Node Names from Self-Hosted Runner
# This script should be run on the GitHub runner that has access to Proxmox

set -e

echo "🔍 Proxmox Node Discovery from Self-Hosted Runner"
echo "================================================="

# Default Proxmox IPs for your environment
PROXMOX_IPS=("172.16.11.1" "172.16.11.2" "172.16.11.3")

echo "🎯 Checking Proxmox nodes at: ${PROXMOX_IPS[*]}"
echo ""

for PROXMOX_IP in "${PROXMOX_IPS[@]}"; do
    echo "🌐 Testing connection to $PROXMOX_IP..."
    PROXMOX_URL="https://${PROXMOX_IP}:8006/api2/json"
    
    # Test basic connectivity
    if curl -k -m 10 -s "$PROXMOX_URL/version" > /dev/null 2>&1; then
        echo "✅ $PROXMOX_IP is reachable"
        
        # Try to get nodes without auth (sometimes works)
        NODES=$(curl -k -m 10 -s "$PROXMOX_URL/nodes" 2>/dev/null | jq -r '.data[]?.node // empty' 2>/dev/null || echo "")
        
        if [ -n "$NODES" ]; then
            echo "📋 Found nodes on $PROXMOX_IP:"
            echo "$NODES" | while read -r node; do
                echo "   - $node"
            done
        else
            echo "🔐 Nodes list requires authentication on $PROXMOX_IP"
        fi
    else
        echo "❌ $PROXMOX_IP is not reachable"
    fi
    echo ""
done

echo "💡 To get detailed node info with authentication:"
echo "   export PROXMOX_TOKEN='your-api-token'"
echo "   export PROXMOX_IP='172.16.11.1'  # or whichever IP works"
echo "   curl -k -H \"Authorization: PVEAPIToken=\$PROXMOX_TOKEN\" \"https://\$PROXMOX_IP:8006/api2/json/nodes\""
echo ""
echo "🎯 Common node names to try:"
echo "   - proxmox, pve, proxmox1, proxmox2, proxmox3"
echo "   - Or the actual hostnames of your servers"
