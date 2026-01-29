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
