terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

#------------------------- State terraform backend location---------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "Your S3 bucket name"
    key    = "terraform.tfstate"
    region = "your region"
  }
}

# --------------------- Determine region from backend data -------------------
provider "aws" {
  region = data.terraform_remote_state.vpc.outputs.aws_region
}

# #--------- Get Ubuntu 20.04 AMI image (SSM Parameter data) -------------------
# data "aws_ssm_parameter" "ubuntu-focal" {
#   name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
# }

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Creating controller node
resource "aws_instance" "controller" {
  #ami                    = data.aws_ssm_parameter.ubuntu-focal.value # from SSM Paramater
  ami = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_1
  vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.Controller-sg_id
  user_data              = file("bootstrap_controller.sh")
  private_ip             = "10.0.1.10"
  monitoring             = true
  key_name               = var.key

  tags = {
    Name  = "${var.environment}-Controller"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

output "Controller" {
  value = [aws_instance.controller.public_ip]
}