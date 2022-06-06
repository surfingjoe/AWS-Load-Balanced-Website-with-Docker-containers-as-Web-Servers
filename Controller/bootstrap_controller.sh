#!/bin/bash
sudo yum -y update

hostnamectl set-hostname Controller
sudo yum install unzip
sudo yum install -y awscli
sudo amazon-linux-extras list | grep ansible2
sudo amazon-linux-extras enable ansible2