provider "google" {
  region      = var.region
  project      = var.project_id
  credentials = file(var.google_account_file)
}

module "packer_build" {
  // source = "../hcpoc-base-packer-centos"
  source                 = "git::ssh://git@github.com/bitrockteam/hcpoc-base-packer-centos?ref=master"
  build_on_google        = true
  google_project_id      = var.project_id
  google_account_file    = abspath(var.google_account_file)
  google_network_name    = google_compute_network.hcpoc.name
  google_subnetwork_name = google_compute_subnetwork.hcpoc.name
  google_firewall_name   = google_compute_firewall.hcpoc_allow_ssh.name
  build_image_name       = var.compute_image_name
  skip_packer_build      = var.skip_packer_build
  build_region           = var.region
  build_zone             = var.zone
}
