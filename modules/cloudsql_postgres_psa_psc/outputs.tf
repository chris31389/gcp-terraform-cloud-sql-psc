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

output "psc_service_attachment_link" {
  description = "Service attachment link for PSC connectivity."
  value       = google_sql_database_instance.postgres.psc_service_attachment_link
}

output "dns_name" {
  description = "Instance-level DNS name (often set for PSC instances)."
  value       = google_sql_database_instance.postgres.dns_name
}

output "network_self_link" {
  description = "VPC network used by the instance."
  value       = local.network_self_link
}
