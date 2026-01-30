output "name" {
  description = "VM instance name."
  value       = google_compute_instance.this.name
}

output "self_link" {
  description = "VM instance self_link."
  value       = google_compute_instance.this.self_link
}

output "internal_ip" {
  description = "VM internal IP address."
  value       = google_compute_instance.this.network_interface[0].network_ip
}

output "external_ip" {
  description = "VM external IP address (null if assign_public_ip=false)."
  value       = try(google_compute_instance.this.network_interface[0].access_config[0].nat_ip, null)
}

output "network_self_link" {
  description = "VPC network self_link used by the VM."
  value       = local.network_self_link
}

output "subnetwork_self_link" {
  description = "Subnetwork self_link used by the VM (null if using an auto-mode network without explicit subnet)."
  value       = local.subnetwork_self_link
}
