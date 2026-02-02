locals {
  zone = "${var.region}-a"

  startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    export DEBIAN_FRONTEND=noninteractive

    apt-get update
    apt-get install -y --no-install-recommends dante-server

    # GCE images often use predictable interface names (e.g., ens4) rather than eth0.
    # If Dante is configured with a non-existent interface, it may fail to start and PSC/DMS
    # will see connection failures.
    EXT_IFACE="$(ip -o -4 route show to default 2>/dev/null | awk '{print $5; exit}')"
    if [[ -z "$${EXT_IFACE}" ]]; then
      EXT_IFACE="ens4"
    fi

    cat > /etc/danted.conf <<CONF
logoutput: syslog

internal: 0.0.0.0 port = ${var.proxy_listen_port}
external: $${EXT_IFACE}

method: none
user.notprivileged: nobody

client pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: connect error
}

socks pass {
  from: 0.0.0.0/0 to: ${var.cloudsql_private_ip}/32 port = ${var.cloudsql_port}
  protocol: tcp
  log: connect error
}
CONF

    systemctl enable danted
    systemctl restart danted
  EOT
}

resource "google_compute_subnetwork" "proxy" {
  name          = var.proxy_subnet_name
  project       = var.project_id
  region        = var.region
  network       = var.network_self_link
  ip_cidr_range = var.proxy_subnet_cidr
}

resource "google_compute_subnetwork" "psc_nat" {
  name          = var.psc_nat_subnet_name
  project       = var.project_id
  region        = var.region
  network       = var.network_self_link
  ip_cidr_range = var.psc_nat_subnet_cidr

  purpose = "PRIVATE_SERVICE_CONNECT"
  role    = "ACTIVE"
}

resource "google_compute_router" "this" {
  name    = var.router_name
  project = var.project_id
  region  = var.region
  network = var.network_self_link
}

resource "google_compute_router_nat" "this" {
  name    = var.nat_name
  project = var.project_id
  region  = var.region
  router  = google_compute_router.this.name

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.proxy.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_instance" "proxy" {
  name         = var.proxy_name
  project      = var.project_id
  zone         = local.zone
  machine_type = var.proxy_machine_type
  labels       = var.labels

  tags = ["dms-psc-proxy"]

  boot_disk {
    initialize_params {
      image = var.proxy_image
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network_self_link
    subnetwork = google_compute_subnetwork.proxy.self_link
  }

  metadata_startup_script = local.startup_script

  depends_on = [google_compute_router_nat.this]
}

resource "google_compute_target_instance" "proxy" {
  name    = "${var.proxy_name}-target"
  project = var.project_id
  zone    = local.zone

  instance = google_compute_instance.proxy.self_link
}

resource "google_compute_forwarding_rule" "proxy" {
  name                  = "${var.proxy_name}-fr"
  project               = var.project_id
  region                = var.region
  network               = var.network_self_link
  subnetwork            = google_compute_subnetwork.proxy.self_link
  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "TCP"
  ports                 = [var.proxy_listen_port]
  target                = google_compute_target_instance.proxy.self_link
  labels                = var.labels
}

resource "google_compute_service_attachment" "this" {
  name    = var.service_attachment_name
  project = var.project_id
  region  = var.region

  connection_preference = var.connection_preference
  enable_proxy_protocol = var.enable_proxy_protocol
  nat_subnets           = [google_compute_subnetwork.psc_nat.self_link]
  target_service        = google_compute_forwarding_rule.proxy.self_link

  dynamic "consumer_accept_lists" {
    for_each = toset(var.consumer_accept_project_numbers)
    content {
      project_id_or_num = consumer_accept_lists.value
      connection_limit  = 10
    }
  }
}

resource "google_compute_firewall" "allow_psc_to_proxy" {
  name    = "${var.proxy_name}-allow-psc"
  project = var.project_id
  network = var.network_self_link

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [var.psc_nat_subnet_cidr]
  target_tags   = ["dms-psc-proxy"]

  allow {
    protocol = "tcp"
    ports    = [tostring(var.proxy_listen_port)]
  }
}
