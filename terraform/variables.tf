variable "aws_region" {
  default = "us-east-2"
  description = "AWS region for deployment"
}

variable "cluster_name" {
  default = "weather-cluster"
  description = "Name of the Weather EKS cluster"
}
