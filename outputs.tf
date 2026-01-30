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
  description = "VM internal IP address (null if create_vm=false)."
  value       = try(module.vm[0].internal_ip, null)
}

output "vm_external_ip" {
  description = "VM external IP address (null if create_vm=false or vm_assign_public_ip=false)."
  value       = try(module.vm[0].external_ip, null)
}
