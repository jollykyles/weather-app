provider "aws" {
  region = "us-east-2"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "weather-cluster"
  cluster_version = "1.31"

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  subnet_ids      = var.subnet_ids
  vpc_id          = var.vpc_id

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

