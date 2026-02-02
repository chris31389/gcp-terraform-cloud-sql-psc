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

variable "vm_name" {
  description = "Name of the VM instance."
  type        = string
  default     = "tf-cheap-vm"
}

variable "vm_assign_public_ip" {
  description = "Whether the VM should have a public IP."
  type        = bool
  default     = true
}

variable "dms_psc_producer_enabled" {
  description = "Whether to create the PSC producer setup used by DMS when migrating to a non-PSC-enabled Cloud SQL private IP destination."
  type        = bool
  default     = true
}

variable "dms_psc_proxy_subnet_name" {
  description = "Subnet name for the DMS PSC proxy VM."
  type        = string
  default     = "dms-psc-proxy-subnet"
}

variable "dms_psc_proxy_subnet_cidr" {
  description = "CIDR for the DMS PSC proxy subnet."
  type        = string
  default     = "10.60.0.0/24"
}

variable "dms_psc_nat_subnet_name" {
  description = "Subnet name for the PSC NAT subnet (purpose PRIVATE_SERVICE_CONNECT)."
  type        = string
  default     = "dms-psc-nat-subnet"
}

variable "dms_psc_nat_subnet_cidr" {
  description = "CIDR for the PSC NAT subnet (purpose PRIVATE_SERVICE_CONNECT)."
  type        = string
  default     = "10.60.1.0/24"
}

variable "dms_psc_proxy_name" {
  description = "Name of the DMS PSC proxy VM."
  type        = string
  default     = "dms-psc-proxy"
}

variable "dms_psc_proxy_listen_port" {
  description = "Port the proxy listens on (default 5432)."
  type        = number
  default     = 5432
}

variable "dms_psc_cloudsql_port" {
  description = "Cloud SQL Postgres port (default 5432)."
  type        = number
  default     = 5432
}

variable "dms_psc_connection_preference" {
  description = "PSC service attachment connection preference: ACCEPT_MANUAL or ACCEPT_AUTOMATIC."
  type        = string
  default     = "ACCEPT_MANUAL"

  validation {
    condition     = contains(["ACCEPT_MANUAL", "ACCEPT_AUTOMATIC"], var.dms_psc_connection_preference)
    error_message = "dms_psc_connection_preference must be ACCEPT_MANUAL or ACCEPT_AUTOMATIC."
  }
}

variable "dms_psc_consumer_accept_project_numbers" {
  description = "Consumer project NUMBERS allowed to connect (only used when ACCEPT_MANUAL)."
  type        = list(string)
  default     = []
}

variable "dms_psc_service_attachment_name" {
  description = "Name of the PSC service attachment resource."
  type        = string
  default     = "dms-psc-service-attachment"
}

variable "dms_psc_router_name" {
  description = "Name of the Cloud Router used by the DMS PSC producer Cloud NAT (dms_psc_producer module)."
  type        = string
  default     = "dms-psc-router"
}

variable "dms_psc_nat_name" {
  description = "Name of the Cloud NAT configuration used by the DMS PSC producer (dms_psc_producer module)."
  type        = string
  default     = "dms-psc-nat"
}

variable "dms_psc_labels" {
  description = "Labels applied to DMS PSC producer resources where supported."
  type        = map(string)
  default     = {}
}
