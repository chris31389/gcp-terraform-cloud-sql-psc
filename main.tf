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
}
