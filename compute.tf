data "google_compute_zones" "available" {
  project = var.project_id
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "hcpoc_cluster_nodes" {
  count = var.cluster_instance_count

  depends_on = [
    google_compute_network.hcpoc,
    module.packer_build
  ]

  project      = var.project_id
  zone         = data.google_compute_zones.available.names[count.index]
  name         = format("clustnode%.2d", count.index + 1)
  machine_type = can(length(var.cluster_machine_type)) ? var.cluster_machine_type : var.default_machine_type

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

  metadata_startup_script = templatefile("${path.module}/scripts/startup-script.sh", {project = var.project_id})

  tags = ["cluster-node", "ssh-allowed-node"]


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

resource "local_file" "ssh_key" {
  sensitive_content = chomp(tls_private_key.ssh-key.private_key_pem)
  filename          = "${path.module}/ssh-key"
  file_permission   = "0600"
}

# data "google_compute_image" "hcpoc_last_image" {
#   family  = var.compute_image_name
#   project = var.project_id
# }

resource "google_compute_instance_template" "worker-instance-template" {
  for_each = var.workers_instance_templates

  name_prefix  = each.value.name_prefix
  machine_type = can(length(each.value.machine_type)) ? each.value.machine_type : var.default_machine_type
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
    source_image = "family/${each.value.image_family_name}"
    # source_image = data.google_compute_image.hcpoc_last_image.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.hcpoc.self_link
    subnetwork = google_compute_subnetwork.hcpoc.self_link
  }

  service_account {
    email  = google_service_account.worker_node_account[each.key].email
    scopes = ["cloud-platform"]
  }

  metadata = {
    vault-agent-config = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/vault-agent-${each.key}.hcl?alt=media"
    consul-agent-config = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/consul-agent-${each.key}.hcl?alt=media"
    consul-agent-ca-file = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/ca.tmpl?alt=media"
    consul-agent-cert-file = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/cert.tmpl?alt=media"
    consul-agent-keyfile-file = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/keyfile.tmpl?alt=media"
    ssh-keys           = "centos:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/startup-script.sh", {project = var.project_id})

  tags = ["ssh-allowed-node", "hcpoc-worker-node"]
}

resource "google_compute_region_instance_group_manager" "default-workers" {
  depends_on = [
    module.consul-cluster
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
}

resource "google_storage_bucket_object" "vault-agent-configs" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "vault-agent-${each.key}.hcl"
  bucket   = google_storage_bucket.configs.name
  content = <<-EOT
      ${templatefile("${path.module}/files/agent.hcl.tpl",
  {
    vault_endpoint      = "http://${google_compute_instance.hcpoc_cluster_nodes[0].name}.c.${var.project_id}.internal:8200"
    tcp_listener        = "127.0.0.1:8200"
    tcp_listener_tls    = false
    gcp_node_role       = "worker-node"
    gcp_service_account = each.value.service_account[0].email
    gcp_project_id      = var.project_id
  }
)}
    EOT
}

resource "google_storage_bucket_object" "consul-agent-configs" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "consul-agent-${each.key}.hcl"
  bucket   = google_storage_bucket.configs.name
  content = <<-EOT
      ${templatefile("${path.module}/files/consul-agent.hcl.tmpl",
  {
    cluster_nodes = { for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.network_ip }
  }
)}
    EOT
}

resource "google_storage_bucket_object" "consul-agent-ca-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "ca.tmpl"
  bucket   = google_storage_bucket.configs.name
  content = file("${path.module}/files/ca.tmpl")
}
resource "google_storage_bucket_object" "consul-agent-cert-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "cert.tmpl"
  bucket   = google_storage_bucket.configs.name
  content = file("${path.module}/files/cert.tmpl")
}
resource "google_storage_bucket_object" "consul-agent-keyfile-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "keyfile.tmpl"
  bucket   = google_storage_bucket.configs.name
  content = file("${path.module}/files/keyfile.tmpl")
}

resource "google_storage_bucket_object" "nomad-client-config" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "nomad-client.hcl"
  bucket   = google_storage_bucket.configs.name
  content = <<-EOT
      ${templatefile("${path.module}/files/nomad-client.hcl.tmpl",
  {
    cluster_nodes = { for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.network_ip }
  }
)}
    EOT
}

resource "null_resource" "restart_vault_agent" {
  for_each = { for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }

  depends_on = [
    google_compute_instance.hcpoc_cluster_nodes,
    google_storage_bucket_object.consul-agent-configs,
    google_compute_region_instance_group_manager.default-workers,
  ]

  connection {
  type        = "ssh"
  user        = var.ssh_user
  private_key = chomp(tls_private_key.ssh-key.private_key_pem)
  timeout     = var.ssh_timeout
  host        = each.value
}

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart vault-agent",
    ]
  }
}