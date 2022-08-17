resource "google_compute_network" "hashicorp" {
  project                 = var.project_id
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

# tfsec:ignore:google-compute-enable-vpc-flow-logs
resource "google_compute_subnetwork" "hashicorp" {
  project                  = var.project_id
  name                     = "${var.prefix}-subnet"
  region                   = var.region
  network                  = google_compute_network.hashicorp.self_link
  ip_cidr_range            = var.subnet_prefix
  private_ip_google_access = true
}

locals {
  hc_ports = var.enable_nomad ? ["8200", "8300", "8500", "4646"] : ["8200", "8300", "8500"]
}

resource "google_compute_firewall" "hashicorp_cluster" {
  project = var.project_id
  name    = "default-allow-cluster"
  network = google_compute_network.hashicorp.self_link

  allow {
    protocol = "tcp"
    ports    = local.hc_ports
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", var.subnet_prefix]
  target_tags   = [local.control_plane_role_name]
}

resource "google_compute_firewall" "hashicorp_allow_ssh" {
  project = var.project_id
  name    = "allow-ssh-to-nodes"
  network = google_compute_network.hashicorp.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ip_list # tfsec:ignore:GCP003
  target_tags   = ["ssh-allowed-node"]
}

resource "google_compute_firewall" "hashicorp_internal_ha" {
  project = var.project_id
  name    = "allow-ha-cluster"
  network = google_compute_network.hashicorp.self_link

  allow {
    protocol = "tcp"
    ports    = ["8201"]
  }

  source_ranges = [var.subnet_prefix]
  target_tags   = [local.control_plane_role_name]
}

resource "google_compute_firewall" "hashicorp_internal_consul_ha" {
  project = var.project_id
  name    = "allow-consul-ha-cluster"
  network = google_compute_network.hashicorp.self_link

  allow {
    protocol = "tcp"
    ports    = ["8301", "8302", "8502", "20000-32000", "9200", "3000", "16686", "14250", "9090", "8080", "9100"]
  }

  allow {
    protocol = "udp"
    ports    = ["6831"]
  }

  source_ranges = [var.subnet_prefix]
  target_tags   = [local.control_plane_role_name, local.worker_plane_role_name]
}

resource "google_compute_firewall" "hashicorp_internal_nomad_ha" {
  count   = var.enable_nomad ? 1 : 0
  project = var.project_id
  name    = "allow-nomad-ha-cluster"
  network = google_compute_network.hashicorp.self_link

  allow {
    protocol = "tcp"
    ports    = ["4646", "4647", "4648"]
  }

  source_ranges = [var.subnet_prefix]
  target_tags   = [local.control_plane_role_name, local.worker_plane_role_name]
}

resource "google_compute_firewall" "hashicorp_ingress" {
  project = var.project_id
  name    = "allow-ingress-ha-cluster"
  network = google_compute_network.hashicorp.self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", var.subnet_prefix]
  target_tags   = [local.worker_plane_role_name]
}

