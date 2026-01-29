provider "google" {
  project = var.project_id
  region  = var.region
}

module "gcs_bucket" {
  source = "./modules/gcs_bucket"

  name          = var.bucket_name
  location      = var.region
  force_destroy = false
  versioning    = true
  labels        = var.labels
}
