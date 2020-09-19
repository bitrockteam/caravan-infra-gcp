resource "google_compute_network" "hcpoc" {
  project                 = var.project_id
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hcpoc" {
  project                  = var.project_id
  name                     = "${var.prefix}-subnet"
  region                   = var.region
  network                  = google_compute_network.hcpoc.self_link
  ip_cidr_range            = var.subnet_prefix
  private_ip_google_access = true
}

resource "google_compute_firewall" "hcpoc_cluster" {
  project = var.project_id
  name    = "default-allow-cluster"
  network = google_compute_network.hcpoc.self_link

  allow {
    protocol = "tcp"
    ports    = ["8200", "8300", "8500", "4646"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
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

resource "google_compute_firewall" "hcpoc_internal_consul_ha" {
  project = var.project_id
  name    = "allow-consul-ha-cluster"
  network = google_compute_network.hcpoc.self_link

  allow {
    protocol = "tcp"
    ports    = ["8301", "8302", "8502", "20000-32000", "9200", "3000", "16686"]
  }

  source_ranges = [var.subnet_prefix]
  target_tags   = ["cluster-node", "hcpoc-worker-node"]
}

resource "google_compute_firewall" "hcpoc_internal_nomad_ha" {
  project = var.project_id
  name    = "allow-nomad-ha-cluster"
  network = google_compute_network.hcpoc.self_link

  allow {
    protocol = "tcp"
    ports    = ["4646", "4647", "4648"]
  }

  source_ranges = [var.subnet_prefix]
  target_tags   = ["cluster-node", "hcpoc-worker-node"]
}

resource "google_compute_firewall" "hcpoc_ingress" {
  project = var.project_id
  name    = "allow-ingress-ha-cluster"
  network = google_compute_network.hcpoc.self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16", var.subnet_prefix]
  target_tags   = ["hcpoc-worker-node"]
}

