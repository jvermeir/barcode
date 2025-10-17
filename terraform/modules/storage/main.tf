# Object Storage module for frontend static files

# Create Object Storage container (bucket)
resource "ovh_cloud_project_containerregistry" "container" {
  service_name = var.project_id
  plan_id      = var.registry_plan
  region       = var.region
  name         = "${var.environment}-${var.bucket_name}-registry"
}

# Create S3 user for storage access
resource "ovh_cloud_project_user" "s3_user" {
  service_name = var.project_id
  description  = "S3 user for frontend bucket access"
  role_name    = "objectstore_operator"
}

# Create S3 credentials
resource "ovh_cloud_project_user_s3_credential" "s3_creds" {
  service_name = var.project_id
  user_id      = ovh_cloud_project_user.s3_user.id
}

# Note: OVH doesn't have a direct Object Storage bucket resource in Terraform
# The bucket needs to be created via API or console, or using null_resource with local-exec
# Below is a placeholder for the bucket configuration

# Create bucket using null_resource (requires OVH CLI or API)
resource "null_resource" "create_bucket" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Bucket creation: ${var.bucket_name}"
      echo "Please create the bucket manually or via OVH API"
      echo "Region: ${var.region}"
      echo "Access Key: ${ovh_cloud_project_user_s3_credential.s3_creds.access_key_id}"
    EOT
  }
  
  triggers = {
    bucket_name = var.bucket_name
    region      = var.region
  }
}

# Output bucket information
locals {
  bucket_url = "https://${var.bucket_name}.${var.region}.cloud.ovh.net"
  s3_endpoint = "https://s3.${var.region}.cloud.ovh.net"
}
