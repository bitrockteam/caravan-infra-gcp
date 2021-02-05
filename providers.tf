provider "google" {
  region      = var.region
  project     = var.project_id
  credentials = file(var.google_account_file)
}

terraform {
  required_version = "~> 0.13.1"
}

provider "acme" {
  server_url = var.use_le_staging ? var.le_staging_endpoint : var.le_production_endpoint
}
