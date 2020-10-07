provider "google" {
  region      = var.region
  project     = var.project_id
  credentials = file(var.google_account_file)
}

terraform {
  required_version = "~> 0.12.28"
}
