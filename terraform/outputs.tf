output "kubeconfig" {
  value = module.eks.cluster_id != null && module.eks.cluster_endpoint != null && module.eks.cluster_certificate_authority_data != null ? templatefile("kubeconfig.tpl", {
    cluster_name = module.eks.cluster_id
    endpoint     = module.eks.cluster_endpoint
    certificate  = module.eks.cluster_certificate_authority_data
  }) : "EKS cluster not created successfully"
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

