provider "google" {
  region      = var.region
  project      = var.project_id
  credentials = file(var.google_account_file)
}


