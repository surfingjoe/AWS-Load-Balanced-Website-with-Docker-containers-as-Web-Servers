terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# ----------  Store Terraform Backend in S3 Bucket --------
terraform {
  backend "s3" {
    bucket = "Your Bucket Name"
    key    = "terraform.tfstate"
    region = "Your Region"
  }
}

# ----------  Region -----------------
provider "aws" {
  region = var.region
}
data "aws_region" "current" {}

# ------------------ Create the VPC -----------------------
resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name  = "${var.environment}-VPC"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# --------------------- Public Subnet #1 -------------------
resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.av-zone1
  cidr_block              = var.public_cidr
  tags = {
    Name  = "${var.environment}-public-1"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# --------------------- Public Subnet #2 ---------------------
resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  map_public_ip_on_launch = true
  availability_zone       = var.av-zone2
  cidr_block              = var.public_cidr2
  tags = {
    Name  = "${var.environment}-public-2"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# ----------------- Internet Gateway -----------------------
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name  = "${var.environment}-IGW"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# ------------------ Setup Route table to IGW  -----------------
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-igw.id
  }
  tags = {
    Name  = "${var.environment}-Public-Route"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# ----------- Setup Public subnet Route table association -------
resource "aws_route_table_association" "public-1-assoc" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.public-route.id
}

# -------- Setup Public subnet #2 Route table association -------
resource "aws_route_table_association" "public-2-assoc" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.public-route.id
}

# --------------------- Private Subnet #1 -------------------
resource "aws_subnet" "private-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  map_public_ip_on_launch = false
  availability_zone       = var.av-zone1
  cidr_block              = var.private_cidr
  tags = {
    Name  = "${var.environment}-private-1"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# --------------------- Private Subnet #2 ---------------------
resource "aws_subnet" "private-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  map_public_ip_on_launch = false
  availability_zone       = var.av-zone2
  cidr_block              = var.private_cidr2
  tags = {
    Name  = "${var.environment}-private-2"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# --------------- Setup NAT for Private Subnet traffic --------------------
resource "aws_instance" "nat" {
  ami = "ami-084f9c6fa14e0b9a5" # AWS NAT instance Publish date: 2022-05-04 
  #ami                         = "ami-0c0b98943e04de199" # Publish date: 2022-03-07
  # "ami-084f9c6fa14e0b9a5" Publish date: 2022-05-04
  # "ami-0046c079820366dc3" Publish date: 2021-07-22
  # "ami-082cb501db4725a9b"  # VNS3 NATe Free (NAT Gateway Appliance)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public-1.id
  vpc_security_group_ids      = ["${aws_security_group.nat-sg.id}", "${aws_security_group.controller-ssh.id}"]
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = file("bootstrap_nat.sh")
  monitoring                  = true
  key_name                    = var.aws_key_name

  tags = {
    Name  = "${var.environment}-NAT1"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}
# --------------- Setup NAT for Private Subnet 2 traffic ------------------
resource "aws_instance" "nat2" {
  ami = "ami-084f9c6fa14e0b9a5" # AWS NAT instance Publish date: 2022-05-04 
  #ami                         = "ami-0c0b98943e04de199" # Publish date: 2022-03-07
  # "ami-084f9c6fa14e0b9a5" Publish date: 2022-05-04
  # "ami-0046c079820366dc3" Publish date: 2021-07-22
  # "ami-082cb501db4725a9b"  # VNS3 NATe Free (NAT Gateway Appliance)
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public-2.id
  vpc_security_group_ids      = ["${aws_security_group.nat-sg.id}", "${aws_security_group.controller-ssh.id}"]
  associate_public_ip_address = true
  source_dest_check           = false

  user_data  = file("bootstrap_nat.sh")
  monitoring = true
  key_name   = var.aws_key_name

  tags = {
    Name  = "${var.environment}-NAT2"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# ------------------ Setup Route to NAT  -----------------
resource "aws_route_table" "nat-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }
  tags = {
    Name  = "${var.environment}-Public-Route"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

resource "aws_route_table_association" "private-route-association" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.nat-route.id
}

# ------------------ Setup Route to NAT2  -----------------
resource "aws_route_table" "nat-route-2" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat2.id
  }
  tags = {
    Name  = "${var.environment}-Public-Route"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

resource "aws_route_table_association" "private-route-association-2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.nat-route-2.id
}

