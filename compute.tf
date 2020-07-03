data "google_compute_zones" "available" {
  project = var.project_id
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "hcpoc_cluster_nodes" {

  depends_on = [
    google_compute_network.hcpoc,
    module.packer_build
  ]

  project      = var.project_id
  count        = var.instance_count
  zone         = data.google_compute_zones.available.names[count.index]
  name         = format("clustnode%.2d", count.index + 1)
  machine_type = "n1-standard-2"

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  boot_disk {
    initialize_params {
      image = "family/${var.compute_image_name}"
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

  tags = ["cluster-node", "ssh-allowed-node", "packer-${var.skip_packer_build ? "old" : module.packer_build.id}"]


  service_account {
    email  = google_service_account.cluster_node_service_account.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

  provisioner "remote-exec" {
    inline = ["echo 'Here come the sun'"]
    connection {
      type        = "ssh"
      user        = var.ssh_user
      timeout     = var.ssh_timeout
      private_key = chomp(tls_private_key.ssh-key.private_key_pem)
      host        = self.network_interface.0.access_config.0.nat_ip
    }
  }
}

resource "google_service_account_iam_binding" "key-account-iam" {
  service_account_id = google_service_account.cluster_node_service_account.id
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.cluster_node_service_account.email}",
  ]
}

resource "local_file" "ssh_key" {
  sensitive_content = chomp(tls_private_key.ssh-key.private_key_pem)
  filename          = "${path.module}/ssh-key"
  file_permission   = "0600"
}

