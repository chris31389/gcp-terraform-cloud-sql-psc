# DMS PSC Producer Setup (for non-PSC Cloud SQL destinations)

This module creates a **PSC producer service attachment** backed by an internal forwarding rule to a small proxy VM. The proxy VM runs a simple Dante SOCKS proxy that can reach a **Cloud SQL private IP** (PSA).

Why this exists:
- Cloud SQL can remain **not PSC-enabled**.
- Database Migration Service (DMS) can still be configured (in the Console) to use **Private IP destination connectivity** by selecting this service attachment.

Outputs:
- `service_attachment_uri`: the service attachment to select in DMS.

Notes:
- This module intentionally does **not** create any DMS resources because (as of provider `hashicorp/google` v7.17.0) Terraform does not expose the destination-PSC service-attachment selection fields for PostgreSQL connection profiles.
