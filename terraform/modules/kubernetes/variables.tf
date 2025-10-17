variable "project_id" {
  description = "OVH Public Cloud Project ID"
  type        = string
}

variable "region" {
  description = "OVH region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "network_id" {
  description = "ID of the private network"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "node_flavor" {
  description = "Flavor for Kubernetes nodes"
  type        = string
  default     = "b2-7"
}

variable "desired_nodes" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "min_nodes" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes"
  type        = number
  default     = 5
}

variable "backend_image" {
  description = "Docker image for the backend application"
  type        = string
}

variable "backend_replicas" {
  description = "Number of backend pod replicas"
  type        = number
  default     = 2
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "enable_ingress" {
  description = "Enable ingress for backend"
  type        = bool
  default     = false
}

variable "backend_domain" {
  description = "Domain for backend ingress"
  type        = string
  default     = ""
}
