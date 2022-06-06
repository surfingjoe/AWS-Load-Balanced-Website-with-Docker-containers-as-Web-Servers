variable "aws_region" {
  type    = string
  default = "Your region"
}

variable "key" {
  type    = string
  default = "Your EC2 Key name"
}
variable "instance_type" {
  description = "Type of EC2 instance to use"
  type        = string
  default     = "t2.micro"
}
variable "environment" {
  description = "User selects environment"
  type        = string
  default     = "Test"
}
variable "your_name" {
  description = "Your Name?"
  type        = string
  default     = "Your name"
}