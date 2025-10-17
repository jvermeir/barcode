output "network_id" {
  description = "ID of the private network"
  value       = ovh_cloud_project_network_private.network.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = ovh_cloud_project_network_private_subnet.subnet.id
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = var.subnet_cidr
}

output "network_name" {
  description = "Name of the network"
  value       = ovh_cloud_project_network_private.network.name
}
