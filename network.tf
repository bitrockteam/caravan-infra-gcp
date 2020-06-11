resource "google_compute_network" "hcpoc" {
  project      = var.project_id
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hcpoc" {
  project      = var.project_id
  name          = "${var.prefix}-subnet"
  region        = var.region
  network       = google_compute_network.hcpoc.self_link
  ip_cidr_range = var.subnet_prefix
}

resource "google_compute_firewall" "workers" {
  project      = var.project_id
  name    = "default-allow-ssh-http"
  network = google_compute_network.hcpoc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["workers"]
}