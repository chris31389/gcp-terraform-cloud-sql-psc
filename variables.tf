variable "project_id" {
  description = "GCP project ID to deploy into."
  type        = string
}

variable "region" {
  description = "Default region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "cloudsql_instance_name" {
  description = "Cloud SQL instance name to create."
  type        = string
  default     = "tf-pg-demo"
}

variable "create_vm" {
  description = "Whether to create a VM instance in the same VPC/subnet as the Cloud SQL instance (for PSA private IP connectivity)."
  type        = bool
  default     = false
}

variable "vm_name" {
  description = "Name of the VM instance (only used when create_vm is true)."
  type        = string
  default     = "tf-cheap-vm"
}

variable "vm_assign_public_ip" {
  description = "Whether the VM should have a public IP (only used when create_vm is true)."
  type        = bool
  default     = true
}
