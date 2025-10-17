# Main Terraform configuration for deploying Barcode App on OVH Cloud

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.35.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
}

# OVH Provider configuration
provider "ovh" {
  endpoint           = var.ovh_endpoint
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_id       = var.ovh_project_id
  region           = var.ovh_region
  network_name     = var.network_name
  subnet_cidr      = var.subnet_cidr
  environment      = var.environment
}

# Kubernetes Cluster Module
module "kubernetes" {
  source = "./modules/kubernetes"

  project_id          = var.ovh_project_id
  region              = var.ovh_region
  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  network_id          = module.networking.network_id
  subnet_id           = module.networking.subnet_id
  environment         = var.environment
  backend_image       = var.backend_image
  backend_replicas    = var.backend_replicas
  db_host             = module.database.db_host
  db_port             = module.database.db_port
  db_name             = module.database.db_name
  db_username         = module.database.db_username
  db_password         = module.database.db_password
}

# PostgreSQL Database Module
module "database" {
  source = "./modules/database"

  project_id    = var.ovh_project_id
  region        = var.ovh_region
  db_name       = var.db_name
  db_version    = var.db_version
  db_plan       = var.db_plan
  environment   = var.environment
  allowed_cidrs = [module.networking.subnet_cidr]
}

# Object Storage Module for Frontend
module "storage" {
  source = "./modules/storage"

  project_id      = var.ovh_project_id
  region          = var.ovh_region
  bucket_name     = var.frontend_bucket_name
  environment     = var.environment
  enable_cdn      = var.enable_cdn
}

# Kubernetes provider configuration using the created cluster
provider "kubernetes" {
  host                   = module.kubernetes.kubeconfig_host
  cluster_ca_certificate = base64decode(module.kubernetes.kubeconfig_ca_cert)
  token                  = module.kubernetes.kubeconfig_token
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes.kubeconfig_host
    cluster_ca_certificate = base64decode(module.kubernetes.kubeconfig_ca_cert)
    token                  = module.kubernetes.kubeconfig_token
  }
}
