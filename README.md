# gcp-terraform-cloud-sql-psc

This repo is set up to run as a Terraform root module and includes a reusable module that creates a simple GCP resource (a Google Cloud Storage bucket).

## What it deploys

- `module.gcs_bucket`: a single `google_storage_bucket`

## Using Terraform Cloud (terraform.io) with VCS integration

1. Create a new Workspace in Terraform Cloud and choose **Version Control Workflow**.
2. Connect this GitHub repo and set the workspace working directory to the repo root.
3. Configure GCP authentication in Terraform Cloud.

### Auth options

**Option A: Service Account JSON (simplest to start)**

- Create a GCP service account with permissions to create storage buckets (e.g. `roles/storage.admin`), and generate a JSON key.
- In Terraform Cloud workspace variables, add an **Environment Variable**:
  - `GOOGLE_CREDENTIALS` = *(paste the full JSON key contents)*

**Option B: Workload Identity Federation (recommended long-term)**

Use Terraform Cloud's OIDC integration with a Google Cloud Workload Identity Provider. This avoids long-lived JSON keys.

## Required Terraform variables

Set these as **Terraform Variables** in the workspace:

- `project_id` (string) — your GCP project ID
- `bucket_name` (string) — must be globally unique

Optional:

- `region` (string) — defaults to `us-central1`
- `labels` (map(string))

## Local usage (optional)

If you want to run locally:

- Install Terraform >= 1.5
- Authenticate to GCP (Application Default Credentials), or export `GOOGLE_CREDENTIALS`

Then:

- `terraform init`
- `terraform plan`
- `terraform apply`

## Module

See `modules/gcs_bucket` for the reusable bucket module.
