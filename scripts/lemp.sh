#!/bin/bash

# Ensure script stops immediately if any step throws an error
set -e

# Update local package definitions
sudo apt update -y

# Install Nginx Web Server, MySQL Database, and PHP Engine components
sudo apt install nginx mysql-server php-fpm php-mysql -y

# Enable and start core background services
sudo systemctl enable nginx
sudo systemctl start nginx

sudo systemctl enable mysql
sudo systemctl start mysql

# Create index directory and deploy sample application payload
sudo mkdir -p /var/www/html
sudo cat <<EOF | sudo tee /var/www/html/index.php
<?php
phpinfo();
?>
EOF

# ========================================================
# POST-DEPLOYMENT VERIFICATION STAGE
# ========================================================
echo "========================================"
echo " RUNNING SYSTEM HEALTH CHECKS          "
echo "========================================"

# 1. Verify Nginx Service Status
if systemctl is-active --quiet nginx; then
    echo "✔ Nginx Web Server: ACTIVE"
else
    echo "❌ Nginx Web Server: FAILED"
fi

# 2. Verify PHP-FPM Service Status (Using default Ubuntu 22.04 LTS version)
if systemctl is-active --quiet php8.1-fpm; then
    echo "✔ PHP-FPM Processor: ACTIVE"
else
    echo "❌ PHP-FPM Processor: FAILED"
fi

# 3. Verify MySQL Service Status
if systemctl is-active --quiet mysql; then
    echo "✔ MySQL Database: ACTIVE"
else
    echo "❌ MySQL Database: FAILED"
fi

# 4. Verify Local HTTP Connectivity
if curl -sI http://localhost | grep -q "HTTP/1.1 200 OK"; then
    echo "✔ Internal HTTP Loopback Connectivity: SUCCESS"
else
    echo "❌ Internal HTTP Loopback Connectivity: FAILED"
fi

# 5. Verify Application Availability
if curl -s http://localhost/index.php | grep -q "phpinfo"; then
    echo "✔ Application Availability (PHP Processing): SUCCESS"
else
    echo "❌ Application Availability (PHP Processing): FAILED"
fi
echo "========================================"