#!/bin/bash

echo "===== Fixing Nginx Configuration for Co-Parent Care ====="

# 1. Create directory for coparentcare website
echo "Creating website directory..."
mkdir -p /home/foe/docker/nextcloud/files/coparentcare

# 2. Create index.html for coparentcare
cat > /home/foe/docker/nextcloud/files/coparentcare/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Co-Parent Care</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            color: #333;
        }
        h1 {
            color: #0078D7;
            text-align: center;
            margin-bottom: 30px;
        }
        .container {
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .coming-soon {
            text-align: center;
            font-size: 1.2em;
            margin: 30px 0;
            color: #555;
        }
    </style>
</head>
<body>
    <h1>Co-Parent Care</h1>
    
    <div class="container">
        <h2>Welcome to Co-Parent Care</h2>
        <p>
            Co-Parent Care is a platform designed to help parents coordinate care for their children
            efficiently and effectively, especially when managing shared custody arrangements.
        </p>
        
        <div class="coming-soon">
            <p><strong>Website coming soon!</strong></p>
            <p>We're working hard to bring you tools that make co-parenting easier.</p>
        </div>
        
        <h3>Our Mission</h3>
        <p>
            Our mission is to reduce stress and improve communication between co-parents,
            ultimately creating a more positive environment for children.
        </p>
    </div>
</body>
</html>
EOF

# 3. Create coparentcare.conf in nginx config directory
echo "Creating nginx configuration for coparentcare.com..."
cat > /home/foe/scripts/git/nginx/conf.d/coparentcare.conf << 'EOF'
server {
    listen 80;
    server_name www.coparentcare.com coparentcare.com;

    access_log /var/log/nginx/coparentcare.access.log;
    error_log /var/log/nginx/coparentcare.error.log;

    # Root directory for the website
    root /var/www/html/coparentcare;
    index index.html index.htm;

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Forward real IP
    real_ip_header X-Forwarded-For;
    set_real_ip_from 0.0.0.0/0;

    # Default location block
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "public, max-age=3600";
    }

    # Static assets with longer cache
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 7d;
    }

    # Do not log favicon.ico requests
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    # Do not log robots.txt requests
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
}
EOF

# 4. Update exchat.conf to remove coparentcare.com
echo "Updating exchat.conf to remove coparentcare.com..."
sed -i 's/server_name exchat.mynetapp.site www.coparentcare.com;/server_name exchat.mynetapp.site;/g' /home/foe/scripts/git/nginx/conf.d/exchat.conf

# 5. Set permissions
echo "Setting permissions..."
chmod -R 755 /home/foe/docker/nextcloud/files/coparentcare
chown -R 1000:1000 /home/foe/docker/nextcloud/files/coparentcare
chown 1000:1000 /home/foe/scripts/git/nginx/conf.d/coparentcare.conf
chown 1000:1000 /home/foe/scripts/git/nginx/conf.d/exchat.conf

echo "===== Configuration complete ====="
echo "Now restart the nginx pod with:"
echo "kubectl rollout restart deployment nginx-workload-deployment -n weapps"