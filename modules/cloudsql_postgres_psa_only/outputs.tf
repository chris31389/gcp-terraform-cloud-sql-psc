output "instance_name" {
  description = "Cloud SQL instance name."
  value       = google_sql_database_instance.postgres.name
}

output "connection_name" {
  description = "Connection name (project:region:instance)."
  value       = google_sql_database_instance.postgres.connection_name
}

output "private_ip_address" {
  description = "Private IP address assigned to the instance (PSA)."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "dns_name" {
  description = "Instance-level DNS name (often set for PSC instances)."
  value       = google_sql_database_instance.postgres.dns_name
}

output "network_self_link" {
  description = "VPC network used by the instance."
  value       = local.network_self_link
}

output "subnetwork_self_link" {
  description = "Subnetwork self_link used by the instance when the module creates a subnet; null when using an existing network or when create_subnet is false."
  value       = var.network_self_link == null && var.create_subnet ? google_compute_subnetwork.this[0].self_link : null
}
