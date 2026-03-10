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
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}


resource "aws_vpc" "isi_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "isi_vpc"
  }
}

resource "aws_subnet" "isi_subnet_public" {
  vpc_id                  = aws_vpc.isi_vpc.id
  cidr_block              = var.subnet_pub_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Subnet = "public"
    Name   = "isi_subnet_public"
  }
}

# resource "aws_subnet" "isi_subnet_private" {
#   vpc_id                  = aws_vpc.isi_vpc.id
#   cidr_block              = var.subnet_priv_cidr_block
#   availability_zone       = var.availability_zone
#   map_public_ip_on_launch = false

#   tags = {
#     Subnet = "private"
#     Name   = "isi_subnet_private"
#   }
# }

resource "aws_internet_gateway" "isi_igw" {
  vpc_id = aws_vpc.isi_vpc.id

  tags = {
    Name = "isi_igw"
  }
}

resource "aws_route_table" "isi_pub_rt" {
  vpc_id = aws_vpc.isi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.isi_igw.id
  }

  tags = {
    Name = "isi_public_rt"
  }
}

resource "aws_route_table_association" "isi_pub_rt_assoc" {
  subnet_id      = aws_subnet.isi_subnet_public.id
  route_table_id = aws_route_table.isi_pub_rt.id
}

# AMI Ubuntu 22.04 LTS (pour user_data avec apt/nginx)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_key_pair" "isi_key_pair" {
  key_name   = "isi_key_pair"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "isi_sg" {
  name        = "isi_sg"
  description = "Security group for ISI instances"
  vpc_id      = aws_vpc.isi_vpc.id

  ingress {
    description = "Allow inbound SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound HTTPS traffic"
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
        Name = "isi_sg"
    }
}


// Public Instance

resource "aws_instance" "isi_public_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.isi_subnet_public.id
  key_name               = aws_key_pair.isi_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.isi_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 80
    volume_type = "gp2"
    encrypted = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "Hello from ISI Public Instance" > /var/www/html/index.html
              EOF

  tags = {
    Name = "isi_public_instance"
  }
}