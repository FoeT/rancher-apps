#!/bin/bash

# This script sets up the necessary files for coparentcare.com

echo "===== Setting up Co-Parent Care website ====="

# 1. Create required directories
echo "Creating directories..."
mkdir -p /home/foe/scripts/git/nginx/conf.d
mkdir -p /home/foe/docker/nextcloud/files/coparentcare

# 2. Copy nginx config file
echo "Copying nginx configuration..."
cp coparentcare.conf /home/foe/scripts/git/nginx/conf.d/

# 3. Copy index.html to the website root
echo "Setting up placeholder web content..."
cp index.html /home/foe/docker/nextcloud/files/coparentcare/

# 4. Set permissions
echo "Setting permissions..."
chmod -R 755 /home/foe/docker/nextcloud/files/coparentcare
chown -R 1000:1000 /home/foe/docker/nextcloud/files/coparentcare
chown -R 1000:1000 /home/foe/scripts/git/nginx/conf.d/coparentcare.conf

# 5. Restart nginx pod to apply changes
echo "Restarting nginx pod..."
kubectl rollout restart deployment nginx-workload-deployment -n weapps

echo "===== Setup Complete ====="
echo "The Co-Parent Care website should now be accessible at:"
echo "  https://www.coparentcare.com"
echo ""
echo "Please note it may take a few minutes for the changes to take effect."