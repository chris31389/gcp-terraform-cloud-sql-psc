variable "name" {
  description = "Name of the VM instance."
  type        = string
}

variable "project_id" {
  description = "GCP project ID to deploy into."
  type        = string
}

variable "region" {
  description = "Region for regional resources like subnet."
  type        = string
}

variable "zone" {
  description = "Zone for the VM instance (e.g., us-central1-a)."
  type        = string
}

variable "machine_type" {
  description = "GCE machine type. Cheapest common option is e2-micro (availability varies by region/zone)."
  type        = string
  default     = "e2-micro"
}

variable "spot" {
  description = "Whether to use Spot/Preemptible capacity (usually cheapest, but can be interrupted)."
  type        = bool
  default     = true
}

variable "allow_stopping_for_update" {
  description = "Whether Terraform is allowed to stop the instance to apply certain updates."
  type        = bool
  default     = true
}

variable "boot_disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 10
}

variable "boot_disk_type" {
  description = "Boot disk type. pd-standard is typically the cheapest."
  type        = string
  default     = "pd-standard"
}

variable "image" {
  description = "Boot image for the VM."
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "labels" {
  description = "Labels applied to the VM and (if created) network resources."
  type        = map(string)
  default     = {}
}

variable "network_self_link" {
  description = "Existing VPC network self_link to use. If null, this module creates a dedicated VPC + subnet."
  type        = string
  default     = null
}

variable "subnetwork_self_link" {
  description = "Existing subnetwork self_link to use when network_self_link is provided."
  type        = string
  default     = null

  validation {
    condition     = var.network_self_link == null || var.subnetwork_self_link != null
    error_message = "When network_self_link is provided, subnetwork_self_link must also be provided (for custom-mode VPCs)."
  }
}

variable "network_name" {
  description = "Name for the VPC created by this module (only used when network_self_link is null)."
  type        = string
  default     = "tf-cheap-vm-vpc"
}

variable "subnet_name" {
  description = "Name for the subnet created by this module (only used when network_self_link is null)."
  type        = string
  default     = "tf-cheap-vm-subnet"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet created by this module (only used when network_self_link is null)."
  type        = string
  default     = "10.20.0.0/24"
}

variable "assign_public_ip" {
  description = "Whether to assign an external IP address (adds an access_config)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Network tags applied to the instance."
  type        = list(string)
  default     = []
}

variable "create_ssh_firewall_rule" {
  description = "Create a basic firewall rule allowing inbound SSH to instances with ssh_tag. Off by default for safety."
  type        = bool
  default     = false
}

variable "ssh_tag" {
  description = "Network tag used by the optional SSH firewall rule."
  type        = string
  default     = "allow-ssh"
}

variable "ssh_source_ranges" {
  description = "Source CIDRs allowed to SSH in the optional firewall rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "service_account_email" {
  description = "Service account email to attach. Use null to attach the project default service account."
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "OAuth scopes for the attached service account."
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write"
  ]
}
