variable "aws_key_name" {
  type    = string
  default = "Mykey"
}
variable "region" {
  type    = string
  default = "us-west-1"
}
variable "environment" {
  description = "User selects environment"
  type        = string
  default     = "Test"
}
variable "your_name" {
  description = "Your Name?"
  type        = string
  default     = "Joe"
}
variable "av-zone1" {
  type    = string
  default = "us-west-1a"
}
variable "av-zone2" {
  type    = string
  default = "us-west-1c"
}
variable "ssh_location" {
  type        = string
  description = "My Public IP Address"
  default     = "172.89.66.78/32"
}
variable "key" {
  type    = string
  default = "JoesKey"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_cidr" {
  type    = string
  default = "10.0.1.0/24"
}
variable "public_cidr2" {
  type    = string
  default = "10.0.2.0/24"
}
variable "private_cidr" {
  type    = string
  default = "10.0.101.0/24"
}
variable "private_cidr2" {
  type    = string
  default = "10.0.102.0/24"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
