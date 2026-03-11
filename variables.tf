# ==============================================================
# PROVIDER - AWS
# ==============================================================
variable "aws_region" {
  description = "Région AWS cible"
  type        = string
  default     = "eu-west-1"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  default     = ""
}

# ==============================================================
# GÉNÉRAL - Projet et environnement
# ==============================================================
variable "project" {
  description = "Nom du projet (préfixe des ressources et tags)"
  type        = string
  default     = "isi_project"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "availability_zone" {
  description = "Availability Zone cible"
  type        = string
}

# ==============================================================
# RÉSEAU - VPC et sous-réseaux
# ==============================================================
variable "vpc_cidr_block" {
  description = "CIDR block du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_pub_cidr_block" {
  description = "CIDR block du subnet public"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_priv_cidr_block" {
  description = "CIDR block du subnet privé (si réactivé)"
  type        = string
  default     = "10.0.2.0/24"
}

# ==============================================================
# SÉCURITÉ - SSH et Security Groups
# ==============================================================
variable "allowed_ssh_cidr" {
  description = "CIDR autorisé pour SSH (ex: ton IP publique /32). En prod, restreindre."
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_key_path" {
  description = "Chemin vers la clé publique SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Chemin vers la clé privée SSH (pour affichage commande SSH)"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# ==============================================================
# AMI - Image de base
# ==============================================================
variable "ami_owner" {
  description = "Owner ID de l'AMI (Canonical pour Ubuntu)"
  type        = string
  default     = "099720109477"
}

variable "ami_name_filter" {
  description = "Filtre nom AMI (Ubuntu 22.04 LTS)"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

# ==============================================================
# EC2 - Instance publique
# ==============================================================
variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "root_volume_size" {
  description = "Taille du volume root en GB"
  type        = number
  default     = 80
}

variable "root_volume_type" {
  description = "Type de volume root (gp2, gp3, etc.)"
  type        = string
  default     = "gp2"
}

variable "instance_user_data_message" {
  description = "Message affiché sur la page index.html de l'instance"
  type        = string
  default     = "Hello from ISI Public Instance"
}
