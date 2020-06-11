data "google_compute_zones" "available" {
  project = var.project_id
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "hcpoc_workers" {
  project      = var.project_id
  count        = var.instance_count
  zone         = data.google_compute_zones.available.names[0]
  name         = "worker-node-${count.index + 1}"
  machine_type = "n1-standard-2"

  boot_disk {
    initialize_params {
      image = "hc-centos-200611143610"
      type = "pd-standard"
      size = "100"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hcpoc.self_link
    access_config {
    }
  }

  metadata = {
    ssh-keys = "centos:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
  }

  depends_on = [google_compute_network.hcpoc]
}
