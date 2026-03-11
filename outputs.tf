# ==============================================================
# VPC & RÉSEAU
# ==============================================================
output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.isi_vpc.id
}

output "public_subnet_id" {
  description = "ID du subnet public"
  value       = aws_subnet.isi_subnet_public.id
}

output "internet_gateway_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.isi_igw.id
}

# ==============================================================
# SECURITY GROUPS
# ==============================================================
output "security_group_id" {
  description = "ID du Security Group des instances publiques"
  value       = aws_security_group.isi_sg.id
}

# ==============================================================
# EC2 - Instance publique
# ==============================================================
output "public_instance_id" {
  description = "ID de l'instance publique"
  value       = aws_instance.isi_public_instance.id
}

output "public_instance_ip" {
  description = "IP publique de l'instance (Nginx)"
  value       = aws_instance.isi_public_instance.public_ip
}

output "public_instance_dns" {
  description = "DNS public de l'instance"
  value       = aws_instance.isi_public_instance.public_dns
}

# ==============================================================
# SSH
# ==============================================================
output "ssh_public_instance" {
  description = "Commande SSH pour se connecter à l'instance publique"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.isi_public_instance.public_ip}"
}
