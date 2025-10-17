# Variables for Barcode App OVH Cloud Deployment

# OVH Authentication
variable "ovh_endpoint" {
  description = "OVH API endpoint (e.g., ovh-eu, ovh-ca, ovh-us)"
  type        = string
  default     = "ovh-eu"
}

variable "ovh_application_key" {
  description = "OVH Application Key"
  type        = string
  sensitive   = true
}

variable "ovh_application_secret" {
  description = "OVH Application Secret"
  type        = string
  sensitive   = true
}

variable "ovh_consumer_key" {
  description = "OVH Consumer Key"
  type        = string
  sensitive   = true
}

variable "ovh_project_id" {
  description = "OVH Public Cloud Project ID"
  type        = string
}

variable "ovh_region" {
  description = "OVH region for resource deployment"
  type        = string
  default     = "GRA11"
}

# Environment
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

# Networking
variable "network_name" {
  description = "Name of the private network"
  type        = string
  default     = "barcode-network"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.0.0/16"
}

# Kubernetes Cluster
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "barcode-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "backend_image" {
  description = "Docker image for the backend application"
  type        = string
  default     = "ghcr.io/jvermeir/barcode-backend:latest"
}

variable "backend_replicas" {
  description = "Number of backend pod replicas"
  type        = number
  default     = 2
}

# Database
variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "barcode"
}

variable "db_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "db_plan" {
  description = "OVH PostgreSQL service plan"
  type        = string
  default     = "essential"
}

# Frontend Storage
variable "frontend_bucket_name" {
  description = "Name of the Object Storage bucket for frontend assets"
  type        = string
  default     = "barcode-frontend"
}

variable "enable_cdn" {
  description = "Enable CDN for frontend delivery"
  type        = bool
  default     = false
}
