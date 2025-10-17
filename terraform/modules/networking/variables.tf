variable "project_id" {
  description = "OVH Public Cloud Project ID"
  type        = string
}

variable "region" {
  description = "OVH region"
  type        = string
}

variable "network_name" {
  description = "Name of the private network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vlan_id" {
  description = "VLAN ID for the private network"
  type        = number
  default     = 0
}

variable "kube_id" {
  description = "Kubernetes cluster ID (optional, for node pool)"
  type        = string
  default     = ""
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
