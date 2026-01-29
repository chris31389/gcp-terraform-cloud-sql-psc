# gcs_bucket module

Creates a single Google Cloud Storage bucket.

## Inputs

- `name` (string, required): globally-unique bucket name
- `location` (string, required): region or multi-region
- `force_destroy` (bool, optional): default `false`
- `versioning` (bool, optional): default `true`
- `labels` (map(string), optional)

## Outputs

- `name`: bucket name
- `url`: `gs://` URL
