resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  service            = "logging.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "serviceusage" {
  service            = "serviceusage.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "cloudkms" {
  service            = "cloudkms.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "dns" {
  service            = "dns.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "containerregistry" {
  service            = "containerregistry.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}