#!/bin/bash

# create dir for certs
sudo mkdir -p ${cert_path}

# private key
sudo bash -c 'cat > ${cert_path}/privkey.pem <<EOF
${privkey_content}
EOF'

# chain
sudo bash -c 'cat > ${cert_path}/fullchain.pem <<EOF
${fullchain_content}
EOF'

# install nginx
sudo apt-get update
sudo apt-get install -y nginx

# default
sudo bash -c 'cat > /etc/nginx/sites-enabled/default <<EOF
# Default server configuration
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	# SSL configuration
	#
	listen 443 ssl default_server;
	listen [::]:443 ssl default_server;

	ssl_certificate ${cert_path}/fullchain.pem; # managed by Certbot
	ssl_certificate_key ${cert_path}/privkey.pem; # managed by Certbot

	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	server_name _;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files \$uri \$uri/ =404;
	}
}
EOF'

# restart nginx
sudo service nginx restart