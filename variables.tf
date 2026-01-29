variable "project_id" {
  description = "GCP project ID to deploy into."
  type        = string
}

variable "region" {
  description = "Default region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Globally-unique GCS bucket name (e.g., my-org-tf-demo-12345)."
  type        = string
}

variable "labels" {
  description = "Labels to apply to created resources."
  type        = map(string)
  default     = {}
}
