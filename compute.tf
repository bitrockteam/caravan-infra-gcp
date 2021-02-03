data "google_compute_zones" "available" {
  project = var.project_id
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "hashicorp_cluster_nodes" {
  count = var.control_plane_instance_count

  depends_on = [
    google_compute_network.hashicorp,
  ]

  project      = var.project_id
  zone         = data.google_compute_zones.available.names[count.index]
  name         = format("clustnode%.2d", count.index + 1)
  machine_type = var.control_plane_machine_type

  scheduling {
    automatic_restart   = ! var.preemptible_instance_type
    on_host_maintenance = var.preemptible_instance_type ? "TERMINATE" : "MIGRATE"
    preemptible         = var.preemptible_instance_type
  }

  boot_disk {
    initialize_params {
      image = var.image
      type  = "pd-standard"
      size  = "100"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hashicorp.self_link
    access_config {
    }
  }

  metadata = {
    ssh-keys                   = "centos:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
    user-data                  = module.cloud_init_control_plane.control_plane_user_data
    serial-port-logging-enable = "TRUE"
  }

  tags = [local.control_plane_role_name, "ssh-allowed-node"]


  service_account {
    email  = google_service_account.control_plane_service_account.email
    scopes = ["cloud-platform", "monitoring", "monitoring-write", "logging-write"]
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

resource "local_file" "ssh_key" {
  sensitive_content = chomp(tls_private_key.ssh-key.private_key_pem)
  filename          = "${path.module}/ssh-key"
  file_permission   = "0600"
}

resource "google_compute_instance_group" "hashicorp_cluster_nodes" {
  depends_on = [
    google_compute_instance.hashicorp_cluster_nodes
  ]

  count = var.control_plane_instance_count

  name = format("unmanaged-hashicorp-clustnode%.2d", count.index + 1)

  instances = [google_compute_instance.hashicorp_cluster_nodes[count.index].id]

  named_port {
    name = "http-ingress"
    port = "8080"
  }

  named_port {
    name = "https-ingress"
    port = "8443"
  }

  named_port {
    name = "vault"
    port = "8200"
  }
  named_port {
    name = "consul"
    port = "8500"
  }
  named_port {
    name = "nomad"
    port = "4646"
  }


  zone = google_compute_instance.hashicorp_cluster_nodes[count.index].zone
}

resource "google_compute_instance_template" "worker-instance-template" {
  for_each = var.workers_instance_templates

  depends_on = [
    google_compute_network.hashicorp,
  ]

  name_prefix  = each.value.name_prefix
  machine_type = var.worker_plane_machine_type
  project      = var.project_id

  lifecycle {
    create_before_destroy = true
  }

  scheduling {
    # Error: Error creating instance template: googleapi: Error 400: Invalid value for field 'resource.properties.scheduling.preemptible': 'true'. 
    # Scheduling must have preemptible be false when AutomaticRestart is true.
    # Scheduling must have preemptible be false when OnHostMaintenance isn't TERMINATE.
    automatic_restart   = ! each.value.preemptible
    on_host_maintenance = each.value.preemptible ? "TERMINATE" : "MIGRATE"
    preemptible         = each.value.preemptible
  }

  disk {
    source_image = var.image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.hashicorp.self_link
    subnetwork = google_compute_subnetwork.hashicorp.self_link
  }

  service_account {
    email  = google_service_account.worker_plane_service_account.email
    scopes = ["cloud-platform", "monitoring", "monitoring-write", "logging-write"]
  }

  metadata = {
    ssh-keys  = "centos:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
    user-data = module.cloud_init_worker_plane.worker_plane_user_data
  }

  tags = [local.worker_plane_role_name, "ssh-allowed-node"]
}

resource "google_compute_region_instance_group_manager" "default-workers" {
  depends_on = [
    module.hashicorp-bootstrap
  ]

  for_each = var.workers_groups

  name                      = "grp-mgr-${each.key}"
  region                    = var.region
  distribution_policy_zones = data.google_compute_zones.available.names
  project                   = var.project_id

  base_instance_name = each.value.base_instance_name
  target_size        = each.value.target_size

  version {
    instance_template = google_compute_instance_template.worker-instance-template[each.value.instance_template].id
  }

  named_port {
    name = "http-ingress"
    port = "8080"
  }
}
