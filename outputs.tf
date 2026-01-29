output "cloudsql_instance_name" {
  description = "Name of the created Cloud SQL instance."
  value       = module.postgres.instance_name
}

output "cloudsql_connection_name" {
  description = "Connection name of the created Cloud SQL instance."
  value       = module.postgres.connection_name
}

output "cloudsql_private_ip" {
  description = "Private IP address assigned to the Cloud SQL instance (PSA)."
  value       = module.postgres.private_ip_address
}

output "cloudsql_psc_service_attachment" {
  description = "PSC service attachment link for the Cloud SQL instance."
  value       = module.postgres.psc_service_attachment_link
}
