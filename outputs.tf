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

output "vm_internal_ip" {
  description = "VM internal IP address."
  value       = module.vm.internal_ip
}

output "vm_external_ip" {
  description = "VM external IP address (null if vm_assign_public_ip=false)."
  value       = module.vm.external_ip
}

output "dms_psc_service_attachment_uri" {
  description = "PSC service attachment URI for DMS destination Private IP connectivity (null if dms_psc_producer_enabled=false)."
  value       = try(module.dms_psc_producer[0].service_attachment_uri, null)
}
