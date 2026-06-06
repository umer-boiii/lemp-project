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

# Dynamically locate the active PHP FastCGI socket file path on the machine
PHP_SOCKET=$(ls /run/php/php*-fpm.sock | head -n 1)

# Overwrite default server block configuration to properly route PHP traffic
# FIX: Added your custom lemp_access.log and lemp_error.log paths directly here!
sudo cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.php index.html index.htm;

    server_name _;

    access_log /var/log/nginx/lemp_access.log;
    error_log /var/log/nginx/lemp_error.log warn;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Pass all raw PHP script executions down the FastCGI process manager socket
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_SOCKET;
    }

    # Deny public directory indexing rules to hidden security structures
    location ~ /\.ht {
        deny all;
    }
}
EOF

# Validate structural integrity syntax parameters of your updated configuration rules
sudo nginx -t

# Cycle Nginx to instantly apply configuration updates
sudo systemctl restart nginx

# =========================================================================
# ⏰ STEP 8 SETUP: AUTOMATE LOG REPORTING CRON JOB
# =========================================================================

# Move the log reporting script into its permanent operations location
sudo mkdir -p /opt/scripts

# FIX: Changed source path to /tmp/scripts/ because that's where the 
# Terraform file provisioner uploads your files!
sudo cp /tmp/scripts/nginx-log-report.sh /opt/scripts/nginx-log-report.sh
sudo chmod +x /opt/scripts/nginx-log-report.sh

# Inject the execution logic pattern safely into the server's root crontab engine
(sudo crontab -l 2>/dev/null | grep -v "nginx-log-report.sh"; echo "0 * * * * /bin/bash /opt/scripts/nginx-log-report.sh") | sudo crontab -
