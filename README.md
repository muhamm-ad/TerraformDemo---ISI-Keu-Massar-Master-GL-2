# TF_DEMO — Infrastructure AWS (Terraform)

Déploiement d’une infrastructure AWS minimale : VPC, subnet public, instance EC2 (Ubuntu + Nginx).

## Prérequis

- [Terraform](https://www.terraform.io/downloads) >= 1.8
- Compte AWS et credentials configurés
- Clé SSH (paire publique/privée)

## Ressources créées

- **Réseau** : VPC, subnet public, Internet Gateway, table de routage
- **Sécurité** : Security group (SSH, HTTP, HTTPS), key pair
- **Compute** : 1 instance EC2 (Ubuntu 22.04, Nginx installé au démarrage)

## Utilisation

1. **Configurer les variables**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

   Éditer `terraform.tfvars` et renseigner au minimum :
   - `availability_zone` (ex. `eu-west-1a`)
   - `aws_access_key` / `aws_secret_key` (ou utiliser les variables d’environnement `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`)
   - `public_key_path` : chemin vers ta clé publique SSH

2. **Initialiser et déployer**

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Connexion SSH**

   Après `apply`, la sortie affiche la commande SSH. Exemple :
   
   ```bash
   ssh -i ~/.ssh/id_rsa ubuntu@<IP_PUBLIQUE>
   ```

4. **Détruire l’infrastructure**

   ```bash
   terraform destroy
   ```

## Fichiers

| Fichier | Rôle |
|--------|------|
| `main.tf` | Provider, VPC, subnet, IGW, route, AMI, key pair, security group, EC2 |
| `variables.tf` | Définition des variables |
| `outputs.tf` | Sorties (IDs, IP, commande SSH) |
| `terraform.tfvars` | Valeurs des variables (à créer à partir de `.example`, ne pas commiter) |
