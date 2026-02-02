provider "google" {
  project = var.project_id
  region  = var.region
}

module "postgres" {
  source = "./modules/cloudsql_postgres_psa_only"

  region        = var.region
  instance_name = var.cloudsql_instance_name
}

module "vm" {
  source = "./modules/vm_instance"

  project_id = var.project_id
  region     = var.region
  zone       = "${var.region}-a"
  name       = var.vm_name

  # Place the VM in the same VPC/subnet as the Cloud SQL private IP (PSA) network.
  create_network       = false
  network_self_link    = module.postgres.network_self_link
  subnetwork_self_link = module.postgres.subnetwork_self_link

  assign_public_ip = var.vm_assign_public_ip
}

module "dms_psc_producer" {
  count  = var.dms_psc_producer_enabled ? 1 : 0
  source = "./modules/dms_psc_producer"

  project_id = var.project_id
  region     = var.region

  network_self_link   = module.postgres.network_self_link
  cloudsql_private_ip = module.postgres.private_ip_address

  proxy_subnet_name   = var.dms_psc_proxy_subnet_name
  proxy_subnet_cidr   = var.dms_psc_proxy_subnet_cidr
  psc_nat_subnet_name = var.dms_psc_nat_subnet_name
  psc_nat_subnet_cidr = var.dms_psc_nat_subnet_cidr

  proxy_name        = var.dms_psc_proxy_name
  proxy_listen_port = var.dms_psc_proxy_listen_port
  cloudsql_port     = var.dms_psc_cloudsql_port

  connection_preference           = var.dms_psc_connection_preference
  consumer_accept_project_numbers = var.dms_psc_consumer_accept_project_numbers

  service_attachment_name = var.dms_psc_service_attachment_name
  labels                  = var.dms_psc_labels
}
