output "db_host" {
  description = "Database host"
  value       = ovh_cloud_project_database.postgres.endpoints[0].domain
}

output "db_port" {
  description = "Database port"
  value       = ovh_cloud_project_database.postgres.endpoints[0].port
}

output "db_name" {
  description = "Database name"
  value       = ovh_cloud_project_database_database.database.name
}

output "db_username" {
  description = "Database username"
  value       = ovh_cloud_project_database_user.user.name
}

output "db_password" {
  description = "Database password"
  value       = ovh_cloud_project_database_user.user.password
  sensitive   = true
}

output "db_uri" {
  description = "Database URI"
  value       = ovh_cloud_project_database.postgres.endpoints[0].uri
  sensitive   = true
}

output "db_id" {
  description = "Database cluster ID"
  value       = ovh_cloud_project_database.postgres.id
}

output "db_status" {
  description = "Database status"
  value       = ovh_cloud_project_database.postgres.status
}
