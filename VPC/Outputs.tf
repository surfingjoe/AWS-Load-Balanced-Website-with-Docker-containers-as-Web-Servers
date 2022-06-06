output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my-vpc.id
}

output "public_subnet_1" {
  description = "Public Subnet 1"
  value       = aws_subnet.public-1.id
}

output "public_subnet_2" {
  description = "Public Subnet 2"
  value       = aws_subnet.public-2.id
}
output "private_subnet_1" {
  description = "Private Subnet 1"
  value       = aws_subnet.private-1.id
}

output "private_subnet_2" {
  description = "Private Subnet 2"
  value       = aws_subnet.private-2.id
}

output "Controller-sg_id" {
  description = "Security group IDs for Controller"
  value       = [aws_security_group.controller-ssh.id]
}

output "lb_security_group_id" {
  description = "Security group IDs for Controller"
  value       = [aws_security_group.lb-sg.id]
}

output "docker-sg_id" {
  description = "Security group IDs for Controller"
  value       = [aws_security_group.docker-sg.id]
}