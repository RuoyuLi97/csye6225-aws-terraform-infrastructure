#!/bin/bash

MYSQL_PRIVATE_IP=$(cat /home/ubuntu/secrets/mysql_private_ip.txt)
echo "MYSQL_PRIVATE_IP is $MYSQL_PRIVATE_IP"

WEBAPP_PRIVATE_IP=$(cat /home/ubuntu/secrets/webapp_private_ip.txt)
echo "WEBAPP_PRIVATE_IP is $WEBAPP_PRIVATE_IP"

scp -o StrictHostKeyChecking=no -i /home/ubuntu/secrets/ec2_key.pem ubuntu@$WEBAPP_PRIVATE_IP:/home/ubuntu/secrets/webapp_private_ip.txt ubuntu@$MYSQL_PRIVATE_IP:webapp_private_ip.txt

ssh -o StrictHostKeyChecking=no -i /home/ubuntu/secrets/ec2_key.pem ubuntu@$MYSQL_PRIVATE_IP << "EOF_REMOTE"
    WEBAPP_PRIVATE_IP=$(cat webapp_private_ip.txt)
    echo "WEBAPP_PRIVATE_IP is $WEBAPP_PRIVATE_IP"

    sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i 's/^mysqlx-bind-address.*/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo systemctl restart mysql

    sudo mysql -u root -e "CREATE USER 'root'@'\${WEBAPP_PRIVATE_IP}' IDENTIFIED BY '';"
    sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'\${WEBAPP_PRIVATE_IP}' WITH GRANT OPTION; FLUSH PRIVILEGES;"
EOF_REMOTE
