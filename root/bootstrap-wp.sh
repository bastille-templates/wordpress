#!/bin/sh
# bootstrap wordpress database and token

## set random token string
BOOTSTRAP_TOKEN=$(openssl rand -base64 12 | sed 's/^/@/g')

## copy config sample into place
cp /usr/local/www/wordpress/wp-config-sample.php /usr/local/www/wordpress/wp-config.php

## find/replace magic
sed -i '' -e s#username_here#wpuser# \
  -e s#password_here#$BOOTSTRAP_TOKEN# \
  -e s#database_name_here#wordpress# \
    /usr/local/www/wordpress/wp-config.php

sed -i '' 's|localhost|127.0.0.1|' /usr/local/www/wordpress/wp-config.php
sed -i '' 's|;date.timezone =|date.timezone ="Asia/Jakarta"|' /usr/local/etc/php.ini
sed -i '' 's|mysqli.default_socket =|mysqli.default_socket =\/var\/run\/mysql\/mysql.sock|' /usr/local/etc/php.ini
sed -i '' 's|pdo_mysql.default_socket=|pdo_mysql.default_socket =\/var\/run\/mysql\/mysql.sock|' /usr/local/etc/php.ini

## import database
mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress;"
mysql -u root -e "CREATE USER IF NOT EXISTS wpuser@localhost identified by '$BOOTSTRAP_TOKEN'"
mysql -u root -e "GRANT ALL PRIVILEGES on wordpress.* to wpuser@localhost"
mysql -u root -e "FLUSH PRIVILEGES"

pkg install -y expect
DB_ROOT_PASSWORD=$(openssl rand -base64 12 | sed 's/^/@/g'); export DB_ROOT_PASSWORD; echo $DB_ROOT_PASSWORD > /root/db_root_pwd.txt

SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Switch to unix_socket authentication\"
send \"y\r\"
expect \"Change the root password?\"
send \"y\r\"
expect \"New password:\"
send \"$DB_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$DB_ROOT_PASSWORD\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
")

echo "$SECURE_MYSQL"

# Display the location of the generated root password for MySQL
echo "Your DB_ROOT_PASSWORD is written on this file /root/db_root_pwd.txt"

# No one but root can read this file. Read only permission.
chmod 400 /root/db_root_pwd.txt

## cleanup
rm /root/bootstrap-wp.sh
