output "bucket_name" {
  description = "Name of the created GCS bucket."
  value       = module.gcs_bucket.name
}

output "bucket_url" {
  description = "gs:// URL of the created GCS bucket."
  value       = module.gcs_bucket.url
}
