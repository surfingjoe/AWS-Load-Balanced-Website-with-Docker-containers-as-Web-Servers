variable "instances_per_subnet" {
  description = "Number of EC2 instances in each private subnet"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Type of EC2 instance to use"
  type        = string
  default     = "t2.micro"
}

variable "environment" {
  description = "User selects environment"
  type = string
  default = "Test"
}

variable "aws_key_name" {
  type    = string
  default = "Mykey"
}

variable "your_name" {
  description = "Your Name?"
  type        = string
  default     = "Joe"
}

variable "ssh_location" {
  type        = string
  description = "My Public IP Address"
  default     = "172.89.66.78/32"
}