output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = ovh_cloud_project_kube.cluster.id
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = ovh_cloud_project_kube.cluster.url
}

output "kubeconfig" {
  description = "Kubeconfig for accessing the cluster"
  value       = ovh_cloud_project_kube_kubeconfig.kubeconfig.content
  sensitive   = true
}

output "kubeconfig_host" {
  description = "Kubernetes API host"
  value       = ovh_cloud_project_kube.cluster.url
}

output "kubeconfig_ca_cert" {
  description = "Kubernetes cluster CA certificate"
  value       = base64encode(ovh_cloud_project_kube.cluster.kubeconfig[0].value)
  sensitive   = true
}

output "kubeconfig_token" {
  description = "Kubernetes authentication token"
  value       = ovh_cloud_project_kube_kubeconfig.kubeconfig.content
  sensitive   = true
}

output "backend_namespace" {
  description = "Kubernetes namespace for backend"
  value       = kubernetes_namespace.backend.metadata[0].name
}

output "backend_service_url" {
  description = "URL of the backend service"
  value       = try(kubernetes_service.backend.status[0].load_balancer[0].ingress[0].ip, "pending")
}

output "cluster_status" {
  description = "Status of the Kubernetes cluster"
  value       = ovh_cloud_project_kube.cluster.status
}
