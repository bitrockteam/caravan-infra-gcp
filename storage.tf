resource "google_storage_bucket" "configs" {
  name               = "cfgs-${var.project_id}"
  location           = var.region
  project            = var.project_id
  force_destroy      = true
  bucket_policy_only = true
  versioning {
    enabled = true
  }
  storage_class = "REGIONAL"
}
