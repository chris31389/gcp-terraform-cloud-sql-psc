locals {
  network_self_link    = var.network_self_link != null ? var.network_self_link : google_compute_network.this[0].self_link
  subnetwork_self_link = var.subnetwork_self_link != null ? var.subnetwork_self_link : (var.network_self_link == null ? google_compute_subnetwork.this[0].self_link : null)

  effective_tags = distinct(concat(
    var.tags,
    var.create_ssh_firewall_rule ? [var.ssh_tag] : [],
    var.enable_iap_ssh ? [var.iap_ssh_tag] : []
  ))
}

data "google_compute_default_service_account" "this" {
  project = var.project_id
}

resource "google_compute_network" "this" {
  count                   = var.network_self_link == null ? 1 : 0
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  count         = var.network_self_link == null ? 1 : 0
  name          = var.subnet_name
  region        = var.region
  network       = google_compute_network.this[0].self_link
  ip_cidr_range = var.subnet_cidr
}

resource "google_compute_firewall" "ssh" {
  count   = var.create_ssh_firewall_rule ? 1 : 0
  name    = "${var.name}-allow-ssh"
  network = local.network_self_link

  direction     = "INGRESS"
  source_ranges = var.ssh_source_ranges
  target_tags   = [var.ssh_tag]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "iap_ssh" {
  count   = var.enable_iap_ssh ? 1 : 0
  name    = "${var.name}-allow-iap-ssh"
  network = local.network_self_link

  direction     = "INGRESS"
  source_ranges = var.iap_ssh_source_ranges
  target_tags   = [var.iap_ssh_tag]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_instance" "this" {
  project      = var.project_id
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"],
      service_account[0].email
    ]
  }

  allow_stopping_for_update = var.allow_stopping_for_update

  labels = var.labels
  tags   = local.effective_tags

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = local.network_self_link
    subnetwork = local.subnetwork_self_link

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {}
    }
  }

  service_account {
    email  = var.service_account_email != null ? var.service_account_email : data.google_compute_default_service_account.this.email
    scopes = var.service_account_scopes
  }

  scheduling {
    preemptible         = var.spot
    automatic_restart   = var.spot ? false : true
    on_host_maintenance = var.spot ? "TERMINATE" : "MIGRATE"
  }

  depends_on = [google_compute_firewall.ssh, google_compute_firewall.iap_ssh]
}
