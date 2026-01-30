variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for PSC producer resources (subnets, proxy VM, forwarding rule, service attachment)."
  type        = string
}

variable "network_self_link" {
  description = "VPC network self_link where the PSC producer setup will be created."
  type        = string
}

variable "cloudsql_private_ip" {
  description = "Private IP address of the destination Cloud SQL instance (PSA)."
  type        = string
}

variable "proxy_subnet_name" {
  description = "Name of the subnet where the proxy VM will live."
  type        = string
  default     = "dms-psc-proxy-subnet"
}

variable "proxy_subnet_cidr" {
  description = "CIDR for the proxy subnet."
  type        = string
  default     = "10.60.0.0/24"
}

variable "psc_nat_subnet_name" {
  description = "Name of the PSC NAT subnet (purpose PRIVATE_SERVICE_CONNECT)."
  type        = string
  default     = "dms-psc-nat-subnet"
}

variable "psc_nat_subnet_cidr" {
  description = "CIDR for the PSC NAT subnet (purpose PRIVATE_SERVICE_CONNECT)."
  type        = string
  default     = "10.60.1.0/24"
}

variable "proxy_name" {
  description = "Name of the proxy VM instance."
  type        = string
  default     = "dms-psc-proxy"
}

variable "proxy_machine_type" {
  description = "Machine type for the proxy VM."
  type        = string
  default     = "e2-micro"
}

variable "proxy_image" {
  description = "Boot image for the proxy VM."
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "proxy_listen_port" {
  description = "Port that the proxy listens on. Default 5432 to match PostgreSQL port."
  type        = number
  default     = 5432
}

variable "cloudsql_port" {
  description = "Port for destination Cloud SQL PostgreSQL."
  type        = number
  default     = 5432
}

variable "connection_preference" {
  description = "Service attachment connection preference. ACCEPT_MANUAL is more restrictive; ACCEPT_AUTOMATIC is easier for quick tests."
  type        = string
  default     = "ACCEPT_MANUAL"

  validation {
    condition     = contains(["ACCEPT_MANUAL", "ACCEPT_AUTOMATIC"], var.connection_preference)
    error_message = "connection_preference must be ACCEPT_MANUAL or ACCEPT_AUTOMATIC."
  }
}

variable "consumer_accept_project_numbers" {
  description = "List of consumer project NUMBERS allowed to connect when connection_preference=ACCEPT_MANUAL. Leave empty to manage approvals manually in the console."
  type        = list(string)
  default     = []
}

variable "service_attachment_name" {
  description = "Name of the PSC service attachment."
  type        = string
  default     = "dms-psc-service-attachment"
}

variable "enable_proxy_protocol" {
  description = "Whether to enable PROXY protocol on the service attachment."
  type        = bool
  default     = false
}

variable "router_name" {
  description = "Name of the Cloud Router used for Cloud NAT."
  type        = string
  default     = "dms-psc-router"
}

variable "nat_name" {
  description = "Name of the Cloud NAT configuration."
  type        = string
  default     = "dms-psc-nat"
}

variable "labels" {
  description = "Labels applied to created resources where supported."
  type        = map(string)
  default     = {}
}
