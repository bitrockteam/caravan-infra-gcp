resource "google_compute_network" "hcpoc" {
  project                 = var.project_id
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hcpoc" {
  project       = var.project_id
  name          = "${var.prefix}-subnet"
  region        = var.region
  network       = google_compute_network.hcpoc.self_link
  ip_cidr_range = var.subnet_prefix
}

resource "google_compute_firewall" "hcpoc_cluster" {
  project = var.project_id
  name    = "default-allow-cluster"
  network = google_compute_network.hcpoc.self_link

  allow {
    protocol = "tcp"
    ports    = ["8200"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cluster-node"]
}

resource "google_compute_firewall" "hcpoc_allow_ssh" {
  project = var.project_id
  name    = "allow-ssh-to-nodes"
  network = google_compute_network.hcpoc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed-node"]
}

resource "google_compute_firewall" "hcpoc_internal_ha" {
  project = var.project_id
  name    = "allow-ha-cluster"
  network = google_compute_network.hcpoc.self_link

  allow {
    protocol = "tcp"
    ports    = ["8201"]
  }

  source_ranges = [var.subnet_prefix]
  target_tags   = ["cluster-node"]
}

