output "service_attachment_uri" {
  description = "PSC service attachment URI. Use this when configuring DMS 'Private IP' destination connectivity in the Console (non-PSC-enabled Cloud SQL approach)."
  value       = google_compute_service_attachment.this.self_link
}

output "proxy_forwarding_rule" {
  description = "Internal forwarding rule backing the PSC service attachment."
  value       = google_compute_forwarding_rule.proxy.self_link
}

output "proxy_internal_ip" {
  description = "Internal IP address of the proxy VM."
  value       = google_compute_instance.proxy.network_interface[0].network_ip
}

output "proxy_subnet" {
  description = "Proxy subnet self_link."
  value       = google_compute_subnetwork.proxy.self_link
}

output "psc_nat_subnet" {
  description = "PSC NAT subnet self_link (purpose PRIVATE_SERVICE_CONNECT)."
  value       = google_compute_subnetwork.psc_nat.self_link
}
