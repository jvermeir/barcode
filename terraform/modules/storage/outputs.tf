output "bucket_name" {
  description = "Name of the bucket"
  value       = var.bucket_name
}

output "bucket_url" {
  description = "URL of the bucket"
  value       = local.bucket_url
}

output "s3_endpoint" {
  description = "S3 endpoint URL"
  value       = local.s3_endpoint
}

output "s3_access_key" {
  description = "S3 access key"
  value       = ovh_cloud_project_user_s3_credential.s3_creds.access_key_id
  sensitive   = true
}

output "s3_secret_key" {
  description = "S3 secret key"
  value       = ovh_cloud_project_user_s3_credential.s3_creds.secret_access_key
  sensitive   = true
}

output "cdn_url" {
  description = "CDN URL (if enabled)"
  value       = var.enable_cdn ? "https://cdn.${var.bucket_name}.${var.region}.cloud.ovh.net" : ""
}

output "registry_url" {
  description = "Container registry URL"
  value       = ovh_cloud_project_containerregistry.container.url
}
