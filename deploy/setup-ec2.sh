#!/usr/bin/env bash
# Aprovisionamiento inicial de la EC2 (Ubuntu 22.04/24.04).
# Se ejecuta UNA vez, por SSH, en la instancia recién creada:
#   scp deploy/nginx.conf deploy/setup-ec2.sh ubuntu@<IP>:~
#   ssh ubuntu@<IP> './setup-ec2.sh'
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y nginx

sudo mkdir -p /var/www/hg-jerseys
sudo chown -R "$USER":"$USER" /var/www/hg-jerseys

sudo cp nginx.conf /etc/nginx/sites-available/hg-jerseys
sudo ln -sf /etc/nginx/sites-available/hg-jerseys /etc/nginx/sites-enabled/hg-jerseys
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "Nginx listo. Sube el sitio a /var/www/hg-jerseys (vía el workflow de GitHub Actions)."
echo "Para HTTPS más adelante (con dominio propio):"
echo "  sudo apt-get install -y certbot python3-certbot-nginx"
echo "  sudo certbot --nginx -d tudominio.com"
