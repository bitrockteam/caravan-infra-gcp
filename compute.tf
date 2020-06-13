data "google_compute_zones" "available" {
  project = var.project_id
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "hcpoc_cluster_nodes" {
  project      = var.project_id
  count        = var.instance_count
  zone         = data.google_compute_zones.available.names[count.index]
  name         = "cluster-node-${count.index + 1}"
  machine_type = "n1-standard-2"

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  boot_disk {
    initialize_params {
      image = "hc-centos-200611143610"
      type  = "pd-standard"
      size  = "100"
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

  metadata_startup_script = file("${path.module}/scripts/startup-script.sh")

  tags = ["cluster-node"]

  depends_on = [google_compute_network.hcpoc]

  service_account {
    email  = google_service_account.cluster_node_service_account.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
}

resource "local_file" "ssh_key" {
  content  = chomp(tls_private_key.ssh-key.private_key_pem)
  filename = "${path.module}/ssh-key"
}

