# cloudsql_postgres_psa_psc module

Creates a minimal-cost Cloud SQL for PostgreSQL instance with:

- Private IP via **Private Service Access (PSA)** using `servicenetworking.googleapis.com`
- **Private Service Connect (PSC)** enabled via `psc_config`

This module focuses on a simple, low-cost baseline:

- `edition` defaults to `ENTERPRISE`
- `tier` defaults to `db-f1-micro` (availability depends on region)
- Zonal availability
- `PD_HDD` and 10GB disk by default
- Backups disabled by default

## Example

```hcl
module "pg" {
  source = "./modules/cloudsql_postgres_psa_psc"

  region        = var.region
  instance_name = "tf-pg-demo"

  # Allow PSC endpoints from this project (add additional projects as needed)
  psc_allowed_consumer_projects = [var.project_id]
}
```

## Inputs (high level)

- `region` (required)
- `instance_name` (required)
- `network_self_link` (optional): use an existing VPC; otherwise the module creates one
- `psc_enabled` (default `true`)
- `psc_allowed_consumer_projects` (default `[]`)

## Outputs

- `private_ip_address`
- `psc_service_attachment_link`
- `connection_name`
