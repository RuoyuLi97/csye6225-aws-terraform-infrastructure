#!/bin/bash

MYSQL_PRIVATE_IP=$(cat /home/ubuntu/secrets/mysql_private_ip.txt)
echo "MYSQL_PRIVATE_IP is $MYSQL_PRIVATE_IP"

DATABASE_USERNAME=$(cat /home/ubuntu/secrets/database_username.txt)
echo "DATABASE_USERNAME is $DATABASE_USERNAME"

DATABASE_PASSWORD=$(cat /home/ubuntu/secrets/database_password.txt)
echo "DATABASE_PASSWORD is $DATABASE_PASSWORD"

echo "Verifying MySQL connection..."
if mysql -h $MYSQL_PRIVATE_IP -u root -e "quit"; then
  echo "MySQL connection successful!"
else
  echo "Failed to connect to MySQL. Exiting."
  exit 1
fi

mysql -h $MYSQL_PRIVATE_IP -u root -e "CREATE DATABASE IF NOT EXISTS recommend;"
if [ $? -eq 0 ]; then
  echo "'recommend' database created or already exists."
else
  echo "Failed to create the 'recommend' database. Exiting."
  exit 1
fi

mysql -h $MYSQL_PRIVATE_IP -u root -e "CREATE USER IF NOT EXISTS '$DATABASE_USERNAME'@'%' IDENTIFIED BY '$DATABASE_PASSWORD';"
mysql -h $MYSQL_PRIVATE_IP -u root -e "GRANT ALL PRIVILEGES ON recommend.* TO '$DATABASE_USERNAME'@'%';"
if [ $? -eq 0 ]; then
  echo "Privileges granted successfully."
else
  echo "Failed to grant privileges. Exiting."
  exit 1
fi

mysql -h $MYSQL_PRIVATE_IP -u root -e "FLUSH PRIVILEGES;"
if [ $? -eq 0 ]; then
  echo "Privileges flushed successfully."
else
  echo "Failed to flush privileges. Exiting."
  exit 1
fi
