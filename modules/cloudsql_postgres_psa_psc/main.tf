locals {
  network_self_link = var.network_self_link != null ? var.network_self_link : google_compute_network.this[0].self_link
}

resource "google_compute_network" "this" {
  count                   = var.network_self_link == null ? 1 : 0
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  count         = var.create_subnet && var.network_self_link == null ? 1 : 0
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.this[0].self_link
  ip_cidr_range = var.subnet_cidr
}

resource "google_compute_global_address" "psa_range" {
  name          = var.psa_reserved_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.psa_reserved_range_prefix_length
  network       = local.network_self_link
}

resource "google_service_networking_connection" "psa" {
  network                 = local.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_range.name]
}

resource "google_sql_database_instance" "this" {
  name             = var.instance_name
  region           = var.region
  database_version = var.database_version

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = "ZONAL"

    disk_type       = var.disk_type
    disk_size       = var.disk_size_gb
    disk_autoresize = true

    user_labels = var.labels

    backup_configuration {
      enabled = var.backups_enabled
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = local.network_self_link

      psc_config {
        psc_enabled               = var.psc_enabled
        allowed_consumer_projects = var.psc_allowed_consumer_projects
        network_attachment_uri    = var.psc_network_attachment_uri
      }
    }
  }

  depends_on = [google_service_networking_connection.psa]
}
