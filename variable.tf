# provider variables

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "availability_zone" {
  description = "AWS availability zone"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_pub_cidr_block" {
  description = "Public subnet CIDR block"
  type = string
  default = "10.0.1.0/24"
}

variable "subnet_priv_cidr_block" {
  description = "Private subnet CIDR block"
  type = string
  default = "10.0.2.0/24"
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "C:/Users/diack/.ssh/id_rsa.pub"
}