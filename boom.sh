#!/bin/bash
set -e

REMOTE_HOST="free-in1.halix.cloud"
REMOTE_USER="tunnel1"
REMOTE_PASS="naksh"

ADMIN_EMAIL="admin@admin.com"
ADMIN_PASS="admin123"
DB_PASSWORD=$(openssl rand -hex 16)
REMOTE_PORT=$(shuf -i 20000-60000 -n 1)

# ===== HALIX PURPLE GRADIENT HEADER =====
clear

g1='\033[38;2;180;120;255m'
g2='\033[38;2;160;90;255m'
g3='\033[38;2;140;60;255m'
g4='\033[38;2;120;30;255m'
g5='\033[38;2;100;0;255m'
nc='\033[0m'

echo -e "${g1}██╗░░██╗░█████╗░██╗░░░░░██╗██╗░░██╗${nc}"
echo -e "${g2}██║░░██║██╔══██╗██║░░░░░██║╚██╗██╔╝${nc}"
echo -e "${g3}███████║███████║██║░░░░░██║░╚███╔╝░${nc}"
echo -e "${g4}██╔══██║██╔══██║██║░░░░░██║░██╔██╗░${nc}"
echo -e "${g5}██║░░██║██║░░██║███████╗██║██╔╝╚██╗${nc}"
echo -e "${g4}╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝╚═╝╚═╝░░╚═╝${nc}"
echo -e "${g3}        HALIX CLOUD • PTERODACTYL AUTO INSTALL${nc}"
echo ""

echo "🚀 Installing Pterodactyl Panel + Tunnel"

apt update && apt upgrade -y
apt install -y curl wget gnupg software-properties-common \
apt-transport-https ca-certificates nginx mariadb-server redis-server \
tar unzip git autossh sshpass

# PHP 8.3
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
apt update
apt install -y php8.3 php8.3-{cli,gd,mysql,pdo,mbstring,tokenizer,bcmath,xml,fpm,curl,zip}
update-alternatives --set php /usr/bin/php8.3

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Database
mysql -e "CREATE DATABASE panel;"
mysql -e "CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1';"
mysql -e "FLUSH PRIVILEGES;"

# Panel install
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzf panel.tar.gz
cp .env.example .env
composer install --no-dev --optimize-autoloader

php artisan key:generate --force

php artisan p:environment:setup \
--author=$ADMIN_EMAIL \
--url=http://localhost \
--timezone=UTC \
--cache=redis \
--session=redis \
--queue=redis \
--settings-ui=true

php artisan p:environment:database \
--host=127.0.0.1 \
--port=3306 \
--database=panel \
--username=pterodactyl \
--password=$DB_PASSWORD

php artisan migrate --seed --force

php artisan p:user:make \
--email="$ADMIN_EMAIL" \
--username="admin" \
--name-first="Admin" \
--name-last="User" \
--password="$ADMIN_PASS" \
--admin=1 \
--no-interaction

# Nginx localhost only
cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 127.0.0.1:80;
    server_name localhost;
    root /var/www/pterodactyl/public;

    index index.php;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
chown -R www-data:www-data /var/www/pterodactyl
systemctl restart nginx

echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1" | crontab -

# ===== START TUNNEL NOW =====
echo ""
echo "🚀 Starting tunnel..."

sshpass -p "$REMOTE_PASS" autossh -M 0 -N \
-R ${REMOTE_PORT}:localhost:80 \
-o StrictHostKeyChecking=no \
-o ServerAliveInterval=30 \
-o ServerAliveCountMax=3 \
${REMOTE_USER}@${REMOTE_HOST} &

sleep 3

URL="http://${REMOTE_HOST}:${REMOTE_PORT}"

echo -e "${g1}==================================================${nc}"
echo -e "${g2}██╗░░██╗░█████╗░██╗░░░░░██╗██╗░░██╗${nc}"
echo -e "${g3}██║░░██║██╔══██╗██║░░░░░██║╚██╗██╔╝${nc}"
echo -e "${g4}███████║███████║██║░░░░░██║░╚███╔╝░${nc}"
echo -e "${g5}██╔══██║██╔══██║██║░░░░░██║░██╔██╗░${nc}"
echo -e "${g4}██║░░██║██║░░██║███████╗██║██╔╝╚██╗${nc}"
echo -e "${g3}╚═╝░░╚═╝╚═╝░░╚═╝╚══════╝╚═╝╚═╝░░╚═╝${nc}"
echo -e "${g2}==================================================${nc}"

echo -e "\033[1;35m✅ PTERODACTYL PANEL IS LIVE${nc}"
echo -e "\033[1;95m🌐 Public URL: $URL${nc}"
echo -e "\033[1;95m📧 Email: $ADMIN_EMAIL${nc}"
echo -e "\033[1;95m🔑 Password: $ADMIN_PASS${nc}"
echo -e "${g1}==================================================${nc}"
echo ""