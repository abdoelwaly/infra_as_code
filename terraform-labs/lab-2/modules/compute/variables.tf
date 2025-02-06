variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "private_sg_id" {
  description = "ID of the private security group"
  type        = string
}

variable "ec2_sg_id" {
  description = "ID of the EC2 security group"
  type        = string
}