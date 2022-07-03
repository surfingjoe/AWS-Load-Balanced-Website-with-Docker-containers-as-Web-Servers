# ------------- Stipulate provider ---------------------------------
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# ------------- Configure the S3 backend for Terraform State -----------
data "terraform_remote_state" "vpc" {
  backend = "s3" 
  config = {
    bucket = "Your S3 bucket name"
    key    = "terraform.tfstate"
    region = "Your region"
  }
}
# ------------- Get the Region data -----------------------------------
provider "aws" {
  region = data.terraform_remote_state.vpc.outputs.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}
# ------------- Get the latest Amazon Linux AMI data -------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
# ------------- Create the Load Balancer ---------------------------------
resource "aws_elb" "elb" {
name= "test-elb"
subnets=[data.terraform_remote_state.vpc.outputs.public_subnet_1,data.terraform_remote_state.vpc.outputs.public_subnet_2]
security_groups = data.terraform_remote_state.vpc.outputs.lb_security_group_id
internal = false

listener {
  instance_port = 80
  instance_protocol = "http"
  lb_port = 80
  lb_protocol = "http"
  }
health_check {
  healthy_threshold = 2
  unhealthy_threshold = 2
  timeout = 3
  target = "HTTP:80/"
  interval = 30
  }
instances = ["${aws_instance.docker1.id}","${aws_instance.docker2.id}","${aws_instance.docker3.id}","${aws_instance.docker4.id}"]
cross_zone_load_balancing = true
idle_timeout = 400
connection_draining = true
connection_draining_timeout = 400

tags = {
  Name          = "${var.environment}-elb"
  Stage         = "${var.environment}"
  Owner         = "${var.your_name}"
  }
}
# ------------- Create the Docker Web Servers----------------------------
resource "aws_instance" "docker1" {
  ami = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type
  key_name               = var.aws_key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_1
  vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.docker-sg_id
  user_data              = file("bootstrap_docker.sh")
  private_ip             = "10.0.101.10"
  tags = {
    Name          = "${var.environment}-Docker_Server1"
    Stage         = "${var.environment}"
    Owner         = "${var.your_name}"
  }
}

resource "aws_instance" "docker2" {
  ami = data.aws_ami.amazon_linux.id
  
  instance_type = var.instance_type
  key_name               = var.aws_key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_1
  vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.docker-sg_id
  user_data              = file("bootstrap_docker.sh")
  private_ip             = "10.0.101.11"
  tags = {
    Name          = "${var.environment}-Docker_Server2"
    Stage         = "${var.environment}"
    Owner         = "${var.your_name}"
  }
}

resource "aws_instance" "docker3" {
  ami = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type
  key_name               = var.aws_key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_2
  vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.docker-sg_id
  user_data              = file("bootstrap_docker.sh")
  private_ip             = "10.0.102.20"
  tags = {
    Name          = "${var.environment}-Docker_Server3"
    Stage         = "${var.environment}"
    Owner         = "${var.your_name}"
  }
}

resource "aws_instance" "docker4" {
  ami = data.aws_ami.amazon_linux.id
  
  instance_type = var.instance_type
  key_name               = var.aws_key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_2
  vpc_security_group_ids = data.terraform_remote_state.vpc.outputs.docker-sg_id
  user_data              = file("bootstrap_docker.sh")
  private_ip             = "10.0.102.21"
  tags = {
    Name          = "${var.environment}-Docker_Server4"
    Stage         = "${var.environment}"
    Owner         = "${var.your_name}"
  }
}
# ------------- Output the load balancer DNS name -----------------------------
output "elb-dns" {
value = "${aws_elb.elb.dns_name}"
}
