data "google_compute_zones" "available" {
  project = var.project_id
}

resource "tls_private_key" "ssh-key" {
  algorithm = "ED25519"
}

# tfsec:ignore:google-compute-no-project-wide-ssh-keys
resource "google_compute_instance" "hashicorp_cluster_nodes" {
  count = var.control_plane_instance_count

  depends_on = [
    google_compute_network.hashicorp,
  ]

  project      = var.project_id
  zone         = data.google_compute_zones.available.names[count.index]
  name         = format("clustnode-%.2d", count.index + 1)
  machine_type = var.control_plane_machine_type

  scheduling {
    automatic_restart   = !var.preemptible_instance_type
    on_host_maintenance = var.preemptible_instance_type ? "TERMINATE" : "MIGRATE"
    preemptible         = var.preemptible_instance_type
  }

  # tfsec:ignore:google-compute-vm-disk-encryption-customer-key
  boot_disk {
    initialize_params {
      image = var.image
      type  = var.volume_root_type
      size  = var.volume_root_size
    }
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

  # tfsec:ignore:google-compute-no-public-ip
  network_interface {
    subnetwork = google_compute_subnetwork.hashicorp.self_link
    access_config {
    }
  }

  metadata = {
    ssh-keys  = "${var.ssh_username}:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
    user-data = module.cloud_init_control_plane.control_plane_user_data
  }

  tags = [local.control_plane_role_name, "ssh-allowed-node"]


  service_account {
    email  = google_service_account.control_plane_service_account.email
    scopes = ["cloud-platform", "monitoring", "monitoring-write", "logging-write"]
  }

  allow_stopping_for_update = true

  lifecycle {
    ignore_changes = [attached_disk]
  }
}


resource "google_compute_attached_disk" "vault_data" {
  count = var.control_plane_instance_count

  disk        = google_compute_disk.vault_data[count.index].id
  instance    = google_compute_instance.hashicorp_cluster_nodes[count.index].id
  device_name = "vault"
}

resource "google_compute_disk" "vault_data" {
  count = var.control_plane_instance_count

  name = format("vault-data-%.2d", count.index + 1)
  zone = google_compute_instance.hashicorp_cluster_nodes[count.index].zone
  type = var.volume_data_type
  size = var.volume_data_size

  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.vault_key.id
  }

  depends_on = [
    google_kms_key_ring_iam_binding.vault_iam_kms_binding
  ]
}


resource "google_compute_attached_disk" "consul_data" {
  count = var.control_plane_instance_count

  disk        = google_compute_disk.consul_data[count.index].id
  instance    = google_compute_instance.hashicorp_cluster_nodes[count.index].id
  device_name = "consul"
}

resource "google_compute_disk" "consul_data" {
  count = var.control_plane_instance_count

  name = format("consul-data-%.2d", count.index + 1)
  zone = google_compute_instance.hashicorp_cluster_nodes[count.index].zone
  type = var.volume_data_type
  size = var.volume_data_size

  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.vault_key.id
  }

  depends_on = [
    google_kms_key_ring_iam_binding.vault_iam_kms_binding
  ]
}


resource "google_compute_attached_disk" "nomad_data" {
  count = var.enable_nomad ? var.control_plane_instance_count : 0

  disk        = google_compute_disk.nomad_data[count.index].id
  instance    = google_compute_instance.hashicorp_cluster_nodes[count.index].id
  device_name = "nomad"
}

resource "google_compute_disk" "nomad_data" {
  count = var.enable_nomad ? var.control_plane_instance_count : 0

  name = format("nomad-data-%.2d", count.index + 1)
  zone = google_compute_instance.hashicorp_cluster_nodes[count.index].zone
  type = var.volume_data_type
  size = var.volume_data_size

  disk_encryption_key {
    kms_key_self_link = google_kms_crypto_key.vault_key.id
  }

  depends_on = [
    google_kms_key_ring_iam_binding.vault_iam_kms_binding
  ]
}

resource "local_sensitive_file" "ssh_key" {
  content         = tls_private_key.ssh-key.private_key_openssh
  filename        = "${path.module}/ssh-key"
  file_permission = "0600"
}

locals {
  named_ports = var.enable_nomad ? [{
    name = "http-ingress"
    port = "8080"
    }, {
    name = "https-ingress"
    port = "8443"
    }, {
    name = "vault"
    port = "8200"
    }, {
    name = "consul"
    port = "8500"
    }, {
    name = "nomad"
    port = "4646"
    }
    ] : [{
      name = "http-ingress"
      port = "8080"
      }, {
      name = "https-ingress"
      port = "8443"
      }, {
      name = "vault"
      port = "8200"
      }, {
      name = "consul"
      port = "8500"
    }
  ]
}

resource "google_compute_instance_group" "hashicorp_cluster_nodes" {
  depends_on = [
    google_compute_instance.hashicorp_cluster_nodes
  ]

  count = var.control_plane_instance_count

  name = format("unmanaged-hashicorp-clustnode-%.2d", count.index + 1)

  instances = [google_compute_instance.hashicorp_cluster_nodes[count.index].self_link]

  dynamic "named_port" {
    for_each = local.named_ports
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
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
    automatic_restart   = !each.value.preemptible
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
    ssh-keys  = "${var.ssh_username}:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
    user-data = module.cloud_init_worker_plane.worker_plane_user_data
  }

  tags = [local.worker_plane_role_name, "ssh-allowed-node"]
}

resource "google_compute_region_instance_group_manager" "default_workers" {
  depends_on = [
    module.caravan-bootstrap
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

# tfsec:ignore:google-compute-no-project-wide-ssh-keys
resource "google_compute_instance" "monitoring_instance" {
  count = var.enable_monitoring ? 1 : 0

  depends_on = [
    google_compute_region_instance_group_manager.default_workers
  ]

  project      = var.project_id
  zone         = var.zone
  name         = "monitoring"
  machine_type = var.worker_plane_machine_type

  scheduling {
    automatic_restart   = !var.preemptible_instance_type
    on_host_maintenance = var.preemptible_instance_type ? "TERMINATE" : "MIGRATE"
    preemptible         = var.preemptible_instance_type
  }

  # tfsec:ignore:google-compute-vm-disk-encryption-customer-key
  boot_disk {
    initialize_params {
      image = var.image
      type  = var.volume_root_type
      size  = var.volume_root_size
    }
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_vtpm                 = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hashicorp.self_link
  }

  metadata = {
    ssh-keys       = "${var.ssh_username}:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
    user-data      = module.cloud_init_worker_plane.monitoring_user_data
    startup-script = module.cloud_init_worker_plane.worker_plane_startup_script
  }

  tags = [local.worker_plane_role_name, "ssh-allowed-node"]

  service_account {
    email  = google_service_account.worker_plane_service_account.email
    scopes = ["cloud-platform", "monitoring", "monitoring-write", "logging-write"]
  }

  allow_stopping_for_update = true

}
