# PostgreSQL database module for OVH Cloud

# Create managed PostgreSQL database
resource "ovh_cloud_project_database" "postgres" {
  service_name = var.project_id
  description  = "${var.environment} PostgreSQL database for Barcode app"
  engine       = "postgresql"
  version      = var.db_version
  plan         = var.db_plan
  
  nodes {
    region = var.region
  }
  
  flavor = var.db_flavor
  
  # Configure disk size
  disk_size = var.disk_size
}

# Create database user
resource "ovh_cloud_project_database_user" "user" {
  service_name = var.project_id
  engine       = ovh_cloud_project_database.postgres.engine
  cluster_id   = ovh_cloud_project_database.postgres.id
  name         = var.db_user_name
}

# Create database
resource "ovh_cloud_project_database_database" "database" {
  service_name = var.project_id
  engine       = ovh_cloud_project_database.postgres.engine
  cluster_id   = ovh_cloud_project_database.postgres.id
  name         = var.db_name
}

# Configure IP restrictions
resource "ovh_cloud_project_database_ip_restriction" "allowed_cidrs" {
  for_each = toset(var.allowed_cidrs)
  
  service_name = var.project_id
  engine       = ovh_cloud_project_database.postgres.engine
  cluster_id   = ovh_cloud_project_database.postgres.id
  ip           = each.value
  description  = "Allow access from ${each.value}"
}

# Database integration
resource "ovh_cloud_project_database_postgresql_user" "user_config" {
  service_name = var.project_id
  cluster_id   = ovh_cloud_project_database.postgres.id
  name         = ovh_cloud_project_database_user.user.name
  
  # Grant privileges
  roles = ["replication"]
  
  depends_on = [ovh_cloud_project_database_database.database]
}
