variable "region" {
  description = "Region for the Cloud SQL instance and (if created) subnet."
  type        = string
}

variable "instance_name" {
  description = "Cloud SQL instance name. Must be 6-30 characters."
  type        = string
}

variable "database_version" {
  description = "Postgres engine version."
  type        = string
  default     = "POSTGRES_17"
}

variable "edition" {
  description = "Cloud SQL edition. Supported values: ENTERPRISE or ENTERPRISE_PLUS."
  type        = string
  default     = "ENTERPRISE"

  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "edition must be one of: ENTERPRISE, ENTERPRISE_PLUS."
  }
}

variable "tier" {
  description = "Machine tier. Cheapest shared-core option is typically db-f1-micro (availability varies by region)."
  type        = string
  default     = "db-f1-micro"
}

variable "disk_type" {
  description = "Disk type. PD_HDD is typically the cheapest."
  type        = string
  default     = "PD_HDD"
}

variable "disk_size_gb" {
  description = "Disk size in GB. Minimum is commonly 10GB."
  type        = number
  default     = 10
}

variable "backups_enabled" {
  description = "Whether automated backups are enabled. Disabling is cheaper but not recommended for production."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether to block Terraform from deleting the instance."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels applied to the instance."
  type        = map(string)
  default     = {}
}

variable "network_self_link" {
  description = "Existing VPC network self_link to use. If null, this module creates a dedicated VPC."
  type        = string
  default     = null
}

variable "network_name" {
  description = "Name for the VPC created by this module (only used when network_self_link is null)."
  type        = string
  default     = "tf-cloudsql-vpc"
}

variable "create_subnet" {
  description = "Whether to create a subnet when creating the VPC."
  type        = bool
  default     = true
}

variable "subnet_name" {
  description = "Name for the subnet created by this module (only used when create_subnet is true and network_self_link is null)."
  type        = string
  default     = "tf-cloudsql-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet created by this module."
  type        = string
  default     = "10.10.0.0/24"
}

variable "psa_reserved_range_name" {
  description = "Name of the reserved internal range used for Private Service Access (service networking)."
  type        = string
  default     = "tf-psa-sql-range"
}

variable "psa_reserved_range_prefix_length" {
  description = "Prefix length for the PSA reserved range. /16 is common for Cloud SQL private services."
  type        = number
  default     = 16
}
