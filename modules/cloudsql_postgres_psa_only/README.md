# cloudsql_postgres_psa_only module

Creates a minimal-cost Cloud SQL for PostgreSQL instance with:

- Private IP via **Private Service Access (PSA)** using `servicenetworking.googleapis.com`

This module focuses on a simple, low-cost baseline:

- `edition` defaults to `ENTERPRISE`
- `tier` defaults to `db-f1-micro` (availability depends on region)
- Zonal availability
- `PD_HDD` and 10GB disk by default
- Backups disabled by default

## Example

```hcl
module "pg" {
  source = "./modules/cloudsql_postgres_psa_only"

  region        = var.region
  instance_name = "tf-pg-demo"
}
```

## Inputs (high level)

- `region` (required)
- `instance_name` (required)
- `network_self_link` (optional): use an existing VPC; otherwise the module creates one

## Outputs

- `private_ip_address`
- `connection_name`
