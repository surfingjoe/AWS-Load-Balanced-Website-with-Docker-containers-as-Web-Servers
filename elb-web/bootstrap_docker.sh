#!/bin/bash
sudo yum install curl
sudo yum -y update
sudo amazon-linux-extras install -y docker
sudo usermod -a -G docker ec2-user
sudo systemctl start docker

sudo docker run -d --name mywebsite -p 80:80 surfingjoe/mywebsite:latest
hostnamectl set-hostname Docker-server