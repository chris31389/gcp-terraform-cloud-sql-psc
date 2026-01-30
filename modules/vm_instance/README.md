# vm_instance module

Creates a minimal-cost Google Compute Engine VM instance.

Defaults are intentionally cost-focused:

- `machine_type` defaults to `e2-micro`
- Spot/Preemptible by default (`spot = true`)
- Small `pd-standard` boot disk (10GB)
- Optional public IP (`assign_public_ip = true`)
- Does **not** open SSH by default (`create_ssh_firewall_rule = false`)

## Example

```hcl
module "vm" {
  source = "./modules/vm_instance"

  project_id = var.project_id
  region     = var.region
  zone       = "us-central1-a"
  name       = "tf-cheap-vm"

  # Optional: enable SSH from your IP(s)
  # create_ssh_firewall_rule = true
  # ssh_source_ranges        = ["203.0.113.10/32"]
}
```

## PSA connectivity to Cloud SQL private IP

To reach a Cloud SQL instance created with PSA (private IP), the VM must be in the same VPC/subnet.

If you are using this repo's Cloud SQL module, you can pass its network outputs into this module:

```hcl
module "postgres" {
  source        = "./modules/cloudsql_postgres_psa_psc"
  region        = var.region
  instance_name = var.cloudsql_instance_name
}

module "vm" {
  source     = "./modules/vm_instance"
  project_id = var.project_id
  region     = var.region
  zone       = "us-central1-a"
  name       = "tf-cheap-vm"

  network_self_link    = module.postgres.network_self_link
  subnetwork_self_link = module.postgres.subnetwork_self_link
}
```

## Notes

- If `network_self_link` is not provided, the module creates a dedicated VPC + subnet.
- If you provide `network_self_link`, you must also provide `subnetwork_self_link` (for custom-mode VPCs).
