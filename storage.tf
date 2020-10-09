resource "google_storage_bucket" "configs" {
  name                        = "cfgs-${var.project_id}"
  location                    = var.region
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  storage_class = "REGIONAL"
}

resource "google_storage_bucket" "registry" {
  name                        = "registry-${var.project_id}"
  location                    = var.region
  project                     = var.project_id
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  storage_class = "REGIONAL"
}