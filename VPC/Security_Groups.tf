# -------------- Security Group for Controller -----------------------
resource "aws_security_group" "controller-ssh" {
  name        = "ssh"
  description = "allow SSH from MyIP"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.ssh_location}"]

  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.environment}-SSH_SG"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}
# -------------- Security Group for NAT instances -----------------------
resource "aws_security_group" "nat-sg" {
  name        = "nat-sg"
  description = "Allow traffic to pass from the private subnet to the internet"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.private_cidr}", "${var.private_cidr2}"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["${var.private_cidr}", "${var.private_cidr2}"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.private_cidr}", "${var.private_cidr2}"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.controller-ssh.id}"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["${var.private_cidr}", "${var.private_cidr2}"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  tags = {
    Name  = "${var.environment}-NAT-Sg"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}
# -------------- Security Group for Docker Servers -----------------------
resource "aws_security_group" "docker-sg" {
  name        = "Docker-SG"
  description = "allow SSH from Controller and HTTP from my IP"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = ["${aws_security_group.controller-ssh.id}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.lb-sg.id}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["${aws_security_group.lb-sg.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.environment}-web-SG"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}

# -------------- Security Group for Load Balancer -----------------------
resource "aws_security_group" "lb-sg" {
  name        = "${var.environment}-lb-SG"
  description = "allow HTTP and HTTPS"
  vpc_id      = aws_vpc.my-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.environment}-lb-SG"
    Stage = "${var.environment}"
    Owner = "${var.your_name}"
  }
}