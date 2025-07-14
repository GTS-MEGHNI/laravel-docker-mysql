#!/bin/bash

# ==========================================

# 1. System Update

# ==========================================

echo "Updating system package lists..."

sudo apt update -y

echo "Upgrading installed packages..."

sudo apt upgrade -y

echo "Cleaning up..."

sudo apt autoremove -y

sudo apt clean

# ==========================================

# 2. Java Installation (for Jenkins)

# ==========================================

echo "Installing OpenJDK 21..."

sudo apt install -y fontconfig openjdk-21-jre

echo "Verifying Java installation..."

java -version

# ==========================================

# 3. Jenkins Installation & Setup

# ==========================================

echo "Adding Jenkins repository and GPG key..."

sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key

echo "Adding Jenkins APT source..."

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | \

sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating package lists for Jenkins..."

sudo apt update -y

echo "Installing Jenkins..."

sudo apt install -y jenkins

echo "Enabling and starting Jenkins service..."

sudo systemctl enable jenkins

sudo systemctl start jenkins

echo "Checking Jenkins service status..."

sudo systemctl status jenkins

# ==========================================

# 4. Install and Configure Nginx

# ==========================================

echo "Installing Nginx..."

sudo apt install -y nginx

echo "Checking Nginx version..."

nginx -v

echo "Starting Nginx..."

sudo service nginx start

sudo systemctl enable nginx

sudo service nginx status

echo "Host IP address:"

hostname -I

# ==========================================

# 5. Install Docker

# ==========================================

echo "Installing Docker dependencies..."

sudo apt install -y ca-certificates curl

echo "Adding Docker GPG key..."

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Setting up Docker APT source..."

echo \

"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \

$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \

sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package lists for Docker..."

sudo apt-get update -y

echo "Installing Docker..."

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Running Docker test container..."

sudo docker run hello-world

# ==========================================

# 6. Add Jenkins to Docker Group

# ==========================================

echo "Adding Jenkins user to Docker group..."

sudo usermod -aG docker jenkins

echo "Restarting Jenkins to apply group changes..."

sudo systemctl restart jenkins

# ==========================================

# 7. Create Docker Network and Run MySQL Container

# ==========================================

NETWORK_NAME="laravel_network"

MYSQL_CONTAINER_NAME="mysql_container"

MYSQL_ROOT_PASSWORD="9e5cda8c-2560-42c8-b6f7-25f9ced85d46" 

VOLUME_NAME="laravel_storage"


echo "Creating Docker network: $NETWORK_NAME..."

sudo docker network inspect $NETWORK_NAME >/dev/null 2>&1 || sudo docker network create $NETWORK_NAME

echo "Creating Docker volume: $VOLUME_NAME..."
sudo docker volume inspect $VOLUME_NAME >/dev/null 2>&1 || sudo docker volume create $VOLUME_NAME

echo "Running MySQL container on $NETWORK_NAME network..."
sudo docker container run -d \
  --name $MYSQL_CONTAINER_NAME \
  --network $NETWORK_NAME \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  -e MYSQL_DATABASE=your_database_name \
  -e MYSQL_USER=your_db_user \
  -e MYSQL_PASSWORD=your_db_password \
  -p 3306:3306 \
  mysql:latest

echo "MySQL container is up and running."
