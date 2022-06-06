# Load balanced website using AWS, EC2 and Docker

## Also, using NAT instances instead of a NAT Gateway
The code found here is a part of my blog on using "Infrastructure as Code" with Terraform.  I'm writing different exercises on how to use Terraform to create AWS deployments in my WordPress site [https://josephomara.com ](https://wordpress.com/post/josephomara.com/990)


<img src="Load Balanced Static Websites.jpg">

## Features
* Using Terraform to create an [Infrastructure as Code](wordpress.com/post/josephomara.com/377)
* The ability to provision resources into AWS using "modular code."
* Four EC2 Web Servers behind a Classic load balancer
* Ability to launch or destroy bastion host (jump server) only when required
	* Can add/remove controller at any time without impact to other resources
	*  	Allows administrator access and operation only when required

## Requirements

- Must have an AWS account
- Install AWS CLI, Configure AWS CLI, Install Terraform
- AWS Administrator account or an account with the following permissions:
  - Privilege to create, read & write an S3 bucket
  - Privilege to create an IAM profile
  - Privilege to create VPC, subnets, and security groups
  - Privilege to create security groups
  - Privilege to create a load balancer, internet gateway, and NAT gateway
  - Privilege to create EC2 images and manage EC2 resources
- Ec2 Key Pair for the region
- Creation of an S3 Bucket to store backend Terraform State
- Create an EC2 Instance as a web server configured as a static website and save image as an AMI. 

## Infrastructure
![](Load Balanced Static Websites with NAT instances (1).jpg)

## Installation
 Clone this repository

* Be sure to change the S3 Bucket name for Terraform remote state
* Be sure to change the variables appropriate to your deployment
* In your terminal, goto the VPC folder and execute the following commands:

   1. `Terraform init`
   2. `terraform validate`
   3. `Terraform apply -var-file=test.tfvars`

* In your terminal goto the elb-web folder and execute the following commands:

   1. `Terraform init`
   2. `terraform validate`
   3. `Terraform apply -var-file=test.tfvars`

   **That's it, you have launched and should now have a load balanced static web site with resilience across availability zones and within each zone have at least two web servers for high availability** 

If you want to actually test the load-balancer feel free to read up on [How to use AWS route 53 to route traffic to an AWS ELB load balancer](docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-to-elb-load-balancer.html).  

The jump server (I call it the controller) can be launched and/or destroyed at any time without impact to the load balancers or web servers.  If you want to launch the jump server, simply change folder to the controller folder and perform the following:

1. `Terraform init`
2. `terraform validate`
3. `Terraform apply`

