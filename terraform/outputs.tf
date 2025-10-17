# Outputs for Barcode App OVH Cloud Deployment

# Networking Outputs
output "network_id" {
  description = "ID of the created private network"
  value       = module.networking.network_id
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = module.networking.subnet_id
}

# Kubernetes Outputs
output "kubernetes_cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = module.kubernetes.cluster_id
}

output "kubernetes_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.kubernetes.cluster_endpoint
}

output "kubeconfig" {
  description = "Kubeconfig for accessing the cluster"
  value       = module.kubernetes.kubeconfig
  sensitive   = true
}

output "backend_namespace" {
  description = "Kubernetes namespace for backend application"
  value       = module.kubernetes.backend_namespace
}

output "backend_service_url" {
  description = "URL of the backend service"
  value       = module.kubernetes.backend_service_url
}

# Database Outputs
output "database_host" {
  description = "PostgreSQL database host"
  value       = module.database.db_host
}

output "database_port" {
  description = "PostgreSQL database port"
  value       = module.database.db_port
}

output "database_name" {
  description = "PostgreSQL database name"
  value       = module.database.db_name
}

output "database_connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${module.database.db_username}@${module.database.db_host}:${module.database.db_port}/${module.database.db_name}"
}

# Storage Outputs
output "frontend_bucket_name" {
  description = "Name of the frontend Object Storage bucket"
  value       = module.storage.bucket_name
}

output "frontend_bucket_url" {
  description = "URL of the frontend bucket"
  value       = module.storage.bucket_url
}

output "frontend_cdn_url" {
  description = "CDN URL for frontend (if enabled)"
  value       = module.storage.cdn_url
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment         = var.environment
    region             = var.ovh_region
    kubernetes_cluster = module.kubernetes.cluster_id
    database_endpoint  = "${module.database.db_host}:${module.database.db_port}"
    frontend_url       = module.storage.bucket_url
    backend_namespace  = module.kubernetes.backend_namespace
  }
}
