# gcp-terraform-cloud-sql-psc

This repo is set up to run as a Terraform root module and includes a reusable module that creates a Cloud SQL for PostgreSQL instance using PSA and/or PSC.

## What it deploys

- `module.postgres`: a Cloud SQL for PostgreSQL instance (private IP via PSA, PSC enabled)
- `modules/vm_instance`: a minimal-cost GCE VM module (optional)

## Using Terraform Cloud (terraform.io) with VCS integration

1. Create a new Workspace in Terraform Cloud and choose **Version Control Workflow**.
2. Connect this GitHub repo and set the workspace working directory to the repo root.
3. Configure GCP authentication in Terraform Cloud.

### Auth options

**Option A: Service Account JSON (simplest to start)**

- Create a GCP service account with permissions to create Cloud SQL instances and set up service networking.
- In Terraform Cloud workspace variables, add an **Environment Variable**:
  - `GOOGLE_CREDENTIALS` = *(paste the full JSON key contents)*

**Option B: Workload Identity Federation (recommended long-term)**

Use Terraform Cloud's OIDC integration with a Google Cloud Workload Identity Provider. This avoids long-lived JSON keys.

## Required Terraform variables

Set these as **Terraform Variables** in the workspace:

- `project_id` (string) — your GCP project ID
- `cloudsql_instance_name` (string) — defaults to `tf-pg-demo`

Optional:

- `region` (string) — defaults to `us-central1`

## Local usage (optional)

If you want to run locally:

- Install Terraform >= 1.5
- Authenticate to GCP (Application Default Credentials), or export `GOOGLE_CREDENTIALS`

Then:

- `terraform init`
- `terraform plan`
- `terraform apply`

## Module

See `modules/cloudsql_postgres_psa_psc` for the reusable Cloud SQL module.
