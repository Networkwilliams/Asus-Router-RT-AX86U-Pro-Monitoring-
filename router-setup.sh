#!/bin/bash
# ASUS Router Setup Script for Monitoring
# Run this script ON THE ROUTER after SSH'ing in manually

echo "=== ASUS Router Monitoring Setup ==="
echo ""

# Step 1: Check USB mount
echo "Step 1: Checking USB drive..."
df -h | grep /tmp/mnt
if [ $? -ne 0 ]; then
    echo "ERROR: No USB drive detected. Please ensure USB is plugged in."
    exit 1
fi
echo "USB drive found!"
echo ""

# Step 2: Launch amtm tool
echo "Step 2: Starting amtm tool for entware installation..."
echo "Once amtm opens:"
echo "  1. Type 'i' and press Enter to install entware"
echo "  2. Follow the prompts to format USB if needed"
echo "  3. After installation completes, type 'e' to exit"
echo ""
read -p "Press Enter to launch amtm..."
amtm

# Step 3: Verify entware installation
echo ""
echo "Step 3: Verifying entware installation..."
if [ -f /opt/bin/opkg ]; then
    echo "Entware installed successfully!"
else
    echo "ERROR: Entware not found. Please run amtm and install entware first."
    exit 1
fi

# Step 4: Update package list
echo ""
echo "Step 4: Updating package list..."
/opt/bin/opkg update

# Step 5: Install Telegraf
echo ""
echo "Step 5: Installing Telegraf..."
/opt/bin/opkg install telegraf

# Step 6: Check installation
echo ""
echo "Step 6: Verifying Telegraf installation..."
/opt/bin/telegraf --version

echo ""
echo "=== Setup Complete! ==="
echo "Next: We'll configure Telegraf to collect router metrics"
