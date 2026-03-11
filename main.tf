# ==============================================================
# TERRAFORM & PROVIDER
# ==============================================================
terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# ==============================================================
# VPC
# ==============================================================
resource "aws_vpc" "isi_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project}-vpc"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================
# SUBNETS
# ==============================================================
resource "aws_subnet" "isi_subnet_public" {
  vpc_id                  = aws_vpc.isi_vpc.id
  cidr_block              = var.subnet_pub_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-subnet-public"
    Project     = var.project
    Environment = var.environment
    Type        = "Public"
    ManagedBy   = "Terraform"
  }
}

# Subnet privé (décommenter si besoin d'une instance privée + NAT)
# resource "aws_subnet" "isi_subnet_private" {
#   vpc_id                  = aws_vpc.isi_vpc.id
#   cidr_block              = var.subnet_priv_cidr_block
#   availability_zone       = var.availability_zone
#   map_public_ip_on_launch = false
#
#   tags = {
#     Name        = "${var.project}-subnet-private"
#     Project     = var.project
#     Environment = var.environment
#     Type        = "Private"
#     ManagedBy   = "Terraform"
#   }
# }

# ==============================================================
# INTERNET GATEWAY
# ==============================================================
resource "aws_internet_gateway" "isi_igw" {
  vpc_id = aws_vpc.isi_vpc.id

  tags = {
    Name        = "${var.project}-igw"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================
# ROUTE TABLES - Public
# ==============================================================
resource "aws_route_table" "isi_pub_rt" {
  vpc_id = aws_vpc.isi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.isi_igw.id
  }

  tags = {
    Name        = "${var.project}-rt-public"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table_association" "isi_pub_rt_assoc" {
  subnet_id      = aws_subnet.isi_subnet_public.id
  route_table_id = aws_route_table.isi_pub_rt.id
}

# ==============================================================
# AMI - Ubuntu 22.04 LTS (pour user_data avec apt/nginx)
# ==============================================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ==============================================================
# KEY PAIR
# ==============================================================
resource "aws_key_pair" "isi_key_pair" {
  key_name   = "${var.project}-keypair"
  public_key = file(var.public_key_path)

  tags = {
    Name        = "${var.project}-keypair"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================
# SECURITY GROUPS
# ==============================================================
resource "aws_security_group" "isi_sg" {
  name        = "${var.project}-sg-public"
  description = "Security group for ISI public instance (SSH, HTTP, HTTPS)"
  vpc_id      = aws_vpc.isi_vpc.id

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-sg-public"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ==============================================================
# EC2 - Instance publique (Nginx)
# ==============================================================
resource "aws_instance" "isi_public_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.isi_subnet_public.id
  key_name                    = aws_key_pair.isi_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.isi_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = true
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "${var.instance_user_data_message}" > /var/www/html/index.html
  EOF

  tags = {
    Name        = "${var.project}-ec2-public"
    Project     = var.project
    Environment = var.environment
    Role        = "WebServer"
    ManagedBy   = "Terraform"
  }
}
