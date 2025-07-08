#!/bin/bash

MYSQL_PRIVATE_IP=$(cat /home/ubuntu/secrets/mysql_private_ip.txt)
echo "MYSQL_PRIVATE_IP is $MYSQL_PRIVATE_IP"

ssh -o StrictHostKeyChecking=no -i /home/ubuntu/secrets/ec2_key.pem ubuntu@$MYSQL_PRIVATE_IP << "EOF_REMOTE"
    sudo mkdir -p /mnt/mysql-data
    sudo mount /dev/xvdf /mnt/mysql-data
    sudo chown -R mysql:mysql /mnt/mysql-data
    sudo chmod -R 755 /mnt/mysql-data

    sudo systemctl stop mysql
    sudo sed -i 's|^#\s*datadir\s*=.*|datadir = /mnt/mysql-data/|' /etc/mysql/mysql.conf.d/mysqld.cnf

    sudo sed -i '/^}$/i\\/mnt/mysql-data/ r,' /etc/apparmor.d/usr.sbin.mysqld
    sudo sed -i '/^}$/i\\/mnt/mysql-data/** rwk,' /etc/apparmor.d/usr.sbin.mysqld
    echo "/dev/xvdf /mnt/mysql-data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

    sudo systemctl restart apparmor
    sudo systemctl start mysql

    echo "=== MySQL: SHOW DATABASES ==="
    sudo mysql -u root -e "SHOW DATABASES;"

    if [ $? -eq 0 ]; then
        echo "MySQL is running, and databases are listed."
    else
        echo "Error: MySQL is not running or data is inaccessible."
    fi
EOF_REMOTE
