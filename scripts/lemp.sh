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