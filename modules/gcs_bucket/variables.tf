variable "name" {
  description = "Globally-unique bucket name."
  type        = string
}

variable "location" {
  description = "Bucket location (region like us-central1, or multi-region like US)."
  type        = string
}

variable "force_destroy" {
  description = "Whether to delete the bucket even if it contains objects."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to the bucket."
  type        = map(string)
  default     = {}
}

variable "versioning" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}
