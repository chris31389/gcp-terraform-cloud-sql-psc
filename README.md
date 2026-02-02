# gcp-terraform-cloud-sql

This repo is set up to run as a Terraform root module and includes a reusable module that creates a Cloud SQL for PostgreSQL instance using PSA and/or PSC.

## What it deploys

- `module.postgres`: a Cloud SQL for PostgreSQL instance (private IP via PSA)
- `modules/vm_instance`: a minimal-cost GCE VM module (optional)
- `modules/dms_psc_producer`: optional PSC producer setup for DMS destination private IP connectivity (keeps Cloud SQL itself non-PSC-enabled)

## Networking (diagram)

The diagram below reflects the networking resources created by this repo:

- Cloud SQL uses **Private Service Access (PSA)** (Service Networking) to get a private IP in your VPC
- The VM is placed in the same VPC/subnet so it can reach the Cloud SQL private IP
- Optional: the `dms_psc_producer` module creates a **PSC service attachment** backed by an internal forwarding rule to a small proxy VM, so **DMS can connect privately** without enabling PSC on the Cloud SQL instance

```mermaid
flowchart TB
  %% Narrower GitHub-friendly layout (top-down)
  %% Solid arrows: traffic flow
  %% Dashed arrows: placement/config (not a hop)

  subgraph Project["GCP project"]
    subgraph VPC["VPC network"]
      CloudSQL["Cloud SQL (Postgres)\nPrivate IP (PSA)"]
      PSA["PSA reserved range"]
      SN["Service Networking"]

      VM["VM (optional)\nclient/test"]

      subgraph PSC["Optional: PSC producer for DMS"]
        SA["Service Attachment"]
        ILBFR["Forwarding rule (ILB)\nTCP:5432"]
        TargetInstance["Target instance"]
        ProxyVM["Proxy VM\nDante SOCKS\n(name suffixed)"]
        FW["Firewall\nPSC NAT → proxy:5432"]
        PSCNAT["PSC NAT subnet"]
        Router["Cloud Router"]
        NAT["Cloud NAT"]
        ProxySubnet["Proxy subnet"]
      end
    end

    DMS["DMS\n(destination profile)"]
  end

  %% PSA path
  PSA --> SN --> CloudSQL
  VM -->|"TCP 5432"| CloudSQL

  %% PSC-for-DMS path
  DMS -->|"PSC"| SA --> ILBFR --> TargetInstance --> ProxyVM -->|"SOCKS"| CloudSQL

  %% Placement/config
  Router --> NAT
  NAT -.-> ProxyVM
  ProxySubnet -.-> ProxyVM
  PSCNAT -.-> SA
  PSCNAT -.-> FW -.-> ProxyVM
```

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
- If using Google credentials, save the JSON credentials to a location and run `setx GOOGLE_APPLICATION_CREDENTIALS "[..Full_Path..]\gcp-sa.json"`

### Local CLI with Terraform Cloud state (optional)

You can run `terraform plan` locally **while using Terraform Cloud for state + locking**.

This repo does **not** force a Terraform Cloud backend by default (so it can be used in different environments). Instead, it provides opt-in example files.

1. Log in to Terraform Cloud locally:
  - `terraform login`
2. Copy the example backend files:
  - Copy `override.tf.example` to `override.tf` (gitignored)
  - Copy `tfc.backend.hcl.example` to `tfc.backend.hcl` (gitignored)
3. Edit `tfc.backend.hcl` and set your Terraform Cloud `organization` + `workspaces.name`.
4. Initialize and plan:
  - `terraform init -backend-config="tfc.backend.hcl"`
  - `terraform plan`

Notes:
- Whether `plan/apply` executes **locally** or **in Terraform Cloud** depends on the Terraform Cloud workspace **Execution Mode**. Either way, state is stored in Terraform Cloud.
- Terraform Cloud workspace variables are automatically used for **remote runs**. For **local CLI runs**, you must provide variables locally (for example via `local.auto.tfvars`, `TF_VAR_*`, or `-var/-var-file`).
- On Windows PowerShell, prefer the `-backend-config="tfc.backend.hcl"` form (flag + separate value). Some setups may misparse the `-backend-config=...` form.

Then:

- `terraform init`
- `terraform plan`
- `terraform apply`

## Troubleshooting

### Error 409: resource already exists (Terraform Cloud runs)

If you see errors like:

`googleapi: Error 409: The resource 'projects/.../zones/.../instances/dms-psc-proxy' already exists`

it means the GCP resource already exists but is **not tracked in the current Terraform state** (common when:
you previously applied from a different Terraform Cloud workspace, deleted state, or created resources manually).

You have two valid paths:

1) **Import** the existing resource into the current state (recommended if you want Terraform to manage it).
   - Configure local CLI to use the same Terraform Cloud workspace state (see "Local CLI with Terraform Cloud state").
   - Then run (example VM import):
     - `terraform import 'module.dms_psc_producer[0].google_compute_instance.proxy' 'projects/<PROJECT>/zones/<REGION>-a/instances/<PROXY_NAME>'`
   - Re-run `terraform plan` and continue importing any other existing resources until the plan is clean.

2) **Rename** the resources to avoid collisions (recommended if the existing resources belong to something else).
   - In Terraform Cloud workspace variables, set unique names like:
     - `dms_psc_proxy_name`
     - `dms_psc_proxy_subnet_name`, `dms_psc_nat_subnet_name`
     - `dms_psc_service_attachment_name`
     - `dms_psc_router_name`, `dms_psc_nat_name`

## Module

See `modules/cloudsql_postgres_psa_psc` for the reusable Cloud SQL module.
See `modules/cloudsql_postgres_psa_only` for the reusable Cloud SQL module.

## DMS to Cloud SQL (private IP destination, Cloud SQL NOT PSC-enabled)

If you need Database Migration Service (DMS) to migrate **into** a Cloud SQL private IP instance **without enabling PSC on the Cloud SQL instance**, this repo includes an optional PSC producer setup.

- Enable it by setting `dms_psc_producer_enabled=true`.
- After apply, use `dms_psc_service_attachment_uri` output when creating the **destination** connection profile in the DMS Console (Private IP).

Note: as of `hashicorp/google` provider v7.17.0, Terraform does not expose the DMS fields needed to attach a destination connection profile to a PSC service attachment for PostgreSQL, so the final DMS destination connection profile step is currently manual.
