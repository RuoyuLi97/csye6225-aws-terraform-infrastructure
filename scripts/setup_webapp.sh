#!/bin/bash
set -e

echo "Configuring web application..."

echo "export MYSQL_PRIVATE_IP='${MYSQL_PRIVATE_IP}'" | sudo tee -a /etc/environment
echo "export DATABASE_USERNAME='${DATABASE_USERNAME}'" | sudo tee -a /etc/environment
echo "export DATABASE_PASSWORD='${DATABASE_PASSWORD}'" | sudo tee -a /etc/environment

source /etc/environment

sudo systemctl set-environment MYSQL_PRIVATE_IP=${MYSQL_PRIVATE_IP}
sudo systemctl set-environment DATABASE_USERNAME=${DATABASE_USERNAME}
sudo systemctl set-environment DATABASE_PASSWORD=${DATABASE_PASSWORD}

sudo systemctl daemon-reload
sudo systemctl restart webapp
sudo systemctl restart nginx

echo "Web application configured successfully."
