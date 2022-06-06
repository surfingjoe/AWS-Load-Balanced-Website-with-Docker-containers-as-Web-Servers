#!/bin/bash
sudo apt-get install curl
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt-get update
sudo apt-get -y upgrade
# sudo apt-get install docker-ce
sudo apt install docker.io -y
sudo docker run -d -p 80:80 surfingjoe/mywebsite
hostnamectl set-hostname Docker-server