provider "aws" {
  region = "us-east-2"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0" # Use the latest compatible version

  cluster_name    = "weather-cluster"
  cluster_version = "1.27"
  vpc_id          = "vpc-0420f341d6543f44a"
  subnet_ids      = ["subnet-051bf6e93be1fe3c9", "subnet-043b60092609d4cae", "subnet-0f37dc2177c07af1e"]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    weather_nodes = {
      desired_capacity = 2
      min_capacity     = 1
      max_capacity     = 3
      instance_type    = "t3.medium"
      additional_security_group_ids = ["sg-0039970cd5044b04f"]
    }
  }


  tags = {
    Environment = "Dev"
  }
}