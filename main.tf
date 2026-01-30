provider "google" {
  project = var.project_id
  region  = var.region
}

module "postgres" {
  source = "./modules/cloudsql_postgres_psa_psc"

  region        = var.region
  instance_name = var.cloudsql_instance_name

  # Allow PSC endpoints from this same project by default.
  psc_allowed_consumer_projects = toset([var.project_id])
  psc_enabled                   = false
}

module "vm" {
  source = "./modules/vm_instance"

  project_id = var.project_id
  region     = var.region
  zone       = "${var.region}-a"
  name       = var.vm_name

  # Place the VM in the same VPC/subnet as the Cloud SQL private IP (PSA) network.
  network_self_link    = module.postgres.network_self_link
  subnetwork_self_link = module.postgres.subnetwork_self_link

  assign_public_ip = var.vm_assign_public_ip
}
