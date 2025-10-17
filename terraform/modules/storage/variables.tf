variable "project_id" {
  description = "OVH Public Cloud Project ID"
  type        = string
}

variable "region" {
  description = "OVH region"
  type        = string
}

variable "bucket_name" {
  description = "Name of the Object Storage bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_cdn" {
  description = "Enable CDN for the bucket"
  type        = bool
  default     = false
}

variable "registry_plan" {
  description = "Container registry plan"
  type        = string
  default     = "SMALL"
}
