#!/bin/sh
# (christer.edwards@gmail.com)
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

sed -i '' 's/localhost/127.0.0.1/' /usr/local/www/wordpress/wp-config.php

## import database
echo "CREATE DATABASE wordpress; CREATE USER wpuser@localhost IDENTIFIED BY
'$BOOTSTRAP_TOKEN'; GRANT ALL PRIVILEGES ON wordpress.* TO wpuser@localhost;" | mysql

pkg install -y expect

# Generate Passowrd Root DB
DB_ROOT_PASSWORD=$(openssl rand -base64 12 | sed 's/^/@/g'); export DB_ROOT_PASSWORD && echo $DB_ROOT_PASSWORD > /root/db_root_pwd.txt

SECURE_MYSQL=$(expect -c "
set timeout 10
set DB_ROOT_PASSWORD "$DB_ROOT_PASSWORD"
spawn mysql_secure_installation
expect \"Press y|Y for Yes, any other key for No:\"
send \"y\r\"
expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:\"
send \"2\r\"
expect \"New password:\"
send \"$DB_ROOT_PASSWORD\r\"
expect \"Re-enter new password:\"
send \"$DB_ROOT_PASSWORD\r\"
expect \"Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) :\"
send \"Y\r\"
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
