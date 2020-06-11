resource "google_storage_bucket" "hcpoc" {
  project      = var.project_id
  name          = "${var.prefix}-storage"
  location      = "us-central1"
  force_destroy = true
  storage_class = "REGIONAL"
}
