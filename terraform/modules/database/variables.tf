variable "project_id" {
  description = "OVH Public Cloud Project ID"
  type        = string
}

variable "region" {
  description = "OVH region"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_version" {
  description = "PostgreSQL version"
  type        = string
}

variable "db_plan" {
  description = "OVH PostgreSQL service plan (essential, business, enterprise)"
  type        = string
}

variable "db_flavor" {
  description = "Database flavor/size"
  type        = string
  default     = "db1-7"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 40
}

variable "db_user_name" {
  description = "Database user name"
  type        = string
  default     = "barcode_user"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access the database"
  type        = list(string)
  default     = []
}
