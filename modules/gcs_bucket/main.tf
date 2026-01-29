resource "google_storage_bucket" "this" {
  name          = var.name
  location      = var.location
  force_destroy = var.force_destroy

  labels = var.labels

  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning
  }
}
