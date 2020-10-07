data "google_compute_zones" "available" {
  project = var.project_id
}

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "google_compute_instance" "hashicorp_cluster_nodes" {
  count = var.cluster_instance_count

  depends_on = [
    google_compute_network.hashicorp,
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
      image = "projects/hcpoc-terraform-admin/global/images/family/${var.prefix}-${var.compute_image_name}"
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
    serial-port-logging-enable = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/startup-script.sh", { project = var.project_id })

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

resource "google_compute_instance_group" "hashicorp_cluster_nodes" {
  depends_on = [
    google_compute_instance.hashicorp_cluster_nodes
  ]

  count = var.cluster_instance_count

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
    source_image = "projects/hcpoc-terraform-admin/global/images/family/${var.prefix}-${var.compute_image_name}"
    auto_delete = true
    boot        = true
  }

  network_interface {
    network    = google_compute_network.hashicorp.self_link
    subnetwork = google_compute_subnetwork.hashicorp.self_link
  }

  service_account {
    email  = google_service_account.worker_node_account[each.key].email
    scopes = ["cloud-platform"]
  }

  metadata = {
    vault-agent-config        = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/vault-agent-${each.key}.hcl?alt=media"
    consul-agent-config       = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/consul-agent-${each.key}.hcl?alt=media"
    consul-agent-ca-file      = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/ca.tmpl?alt=media"
    consul-agent-cert-file    = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/cert.tmpl?alt=media"
    consul-agent-keyfile-file = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/keyfile.tmpl?alt=media"
    nomad-agent-ca-file       = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/nomad_ca.tmpl?alt=media"
    nomad-agent-cert-file     = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/nomad_cert.tmpl?alt=media"
    nomad-agent-keyfile-file  = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/nomad_keyfile.tmpl?alt=media"
    nomad-client-config       = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/nomad.hcl.tmpl?alt=media"
    ssh-keys                  = "centos:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/startup-script.sh", { project = var.project_id })

  tags = ["ssh-allowed-node", "hashicorp-worker-node"]
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


resource "google_compute_instance" "monitoring_instance" {
  project      = var.project_id
  zone         = "us-central1-a"
  name         = "monitoring"
  machine_type = can(length(var.monitoring_machine_type)) ? var.monitoring_machine_type : var.default_machine_type

  depends_on = [
    google_compute_network.hashicorp,
  ]

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  boot_disk {
    initialize_params {
      image = "projects/hcpoc-terraform-admin/global/images/family/${var.prefix}-${var.compute_image_name}"
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
    vault-agent-config        = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/vault-agent-def-wrkr.hcl?alt=media"
    consul-agent-config       = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/consul-agent-def-wrkr.hcl?alt=media"
    consul-agent-ca-file      = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/ca.tmpl?alt=media"
    consul-agent-cert-file    = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/cert.tmpl?alt=media"
    consul-agent-keyfile-file = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/keyfile.tmpl?alt=media"
    nomad-agent-ca-file       = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/nomad_ca.tmpl?alt=media"
    nomad-agent-cert-file     = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/nomad_cert.tmpl?alt=media"
    nomad-agent-keyfile-file  = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/nomad_keyfile.tmpl?alt=media"
    nomad-client-config       = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/nomad.hcl.tmpl?alt=media"
    elastic-service           = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/elastic-service.json?alt=media"
    grafana-service           = "https://storage.googleapis.com/download/storage/v1/b/${google_storage_bucket.configs.name}/o/grafana-service.json?alt=media"
    ssh-keys                  = "centos:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/startup-script-monitoring.sh", { project = var.project_id })

  tags = ["ssh-allowed-node", "hashicorp-worker-node"]

  service_account {
    email  = google_service_account.cluster_node_service_account.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

}

resource "google_storage_bucket_object" "vault-agent-configs" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "vault-agent-${each.key}.hcl"
  bucket   = google_storage_bucket.configs.name
  content = <<-EOT
      ${templatefile("${path.module}/files/agent.hcl.tpl",
  {
    vault_endpoint      = "http://${google_compute_instance.hashicorp_cluster_nodes[0].name}.c.${var.project_id}.internal:8200"
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
    cluster_nodes = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip },
    dc_name       = var.dc_name
  }
)}
    EOT
}

resource "google_storage_bucket_object" "consul-agent-ca-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "ca.tmpl"
  bucket   = google_storage_bucket.configs.name
  content  = file("${path.module}/files/ca.tmpl")
}

resource "google_storage_bucket_object" "consul-agent-cert-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "cert.tmpl"
  bucket   = google_storage_bucket.configs.name
  content = <<-EOT
      ${templatefile("${path.module}/files/cert.tmpl",
  {
    dc_name = var.dc_name
  }
)}
    EOT
}

resource "google_storage_bucket_object" "consul-agent-keyfile-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "keyfile.tmpl"
  bucket   = google_storage_bucket.configs.name
  content = <<-EOT
      ${templatefile("${path.module}/files/keyfile.tmpl",
  {
    dc_name = var.dc_name
  }
)}
    EOT
}

resource "google_storage_bucket_object" "nomad-client-config" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "nomad.hcl.tmpl"
  bucket   = google_storage_bucket.configs.name
  content = <<-EOT
      ${templatefile("${path.module}/files/nomad-client.hcl.tmpl",
  {
    cluster_nodes = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip },
    dc_name       = var.dc_name
  }
)}
    EOT
}

resource "google_storage_bucket_object" "nomad-agent-ca-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "nomad_ca.tmpl"
  bucket   = google_storage_bucket.configs.name
  content  = file("${path.module}/files/nomad_ca.tmpl")
}

resource "google_storage_bucket_object" "nomad-agent-cert-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "nomad_cert.tmpl"
  bucket   = google_storage_bucket.configs.name
  content  = file("${path.module}/files/nomad_cert.tmpl")
}

resource "google_storage_bucket_object" "nomad-agent-keyfile-file" {
  for_each = google_compute_instance_template.worker-instance-template
  name     = "nomad_keyfile.tmpl"
  bucket   = google_storage_bucket.configs.name
  content  = file("${path.module}/files/nomad_keyfile.tmpl")
}

### monitoring

resource "google_storage_bucket_object" "elastic-service-file" {
  name    = "elastic-service.json"
  bucket  = google_storage_bucket.configs.name
  content = file("${path.module}/files/elastic-service.json")
}

resource "google_storage_bucket_object" "grafana-service-file" {
  name    = "grafana-service.json"
  bucket  = google_storage_bucket.configs.name
  content = file("${path.module}/files/grafana-service.json")
}

resource "google_storage_bucket_object" "java_springboot_artifact" {
  name   = "spring-echo-example-1.0.0.jar"
  bucket = google_storage_bucket.configs.name
  source = "${path.module}/files/spring-echo-example-1.0.0.jar"
}

resource "google_storage_bucket_object" "echo_server_artifact" {
  name   = "echo-server"
  bucket = google_storage_bucket.configs.name
  source = "${path.module}/files/echo-server"
}

resource "google_storage_bucket_object" "java_opntrc_artifact" {
  name   = "OpenTracing-AppA-0.0.1-SNAPSHOT.jar"
  bucket = google_storage_bucket.configs.name
  source = "${path.module}/files/OpenTracing-AppA-0.0.1-SNAPSHOT.jar"
}

resource "google_storage_bucket_object" "java_opntrc_artifact_b" {
  name   = "OpenTracing-AppB-0.0.1-SNAPSHOT.jar"
  bucket = google_storage_bucket.configs.name
  source = "${path.module}/files/OpenTracing-AppB-0.0.1-SNAPSHOT.jar"
}

resource "google_storage_bucket_object" "jaeger-spark" {
  name   = "jaeger-spark-dependencies-0.0.1-SNAPSHOT.jar"
  bucket = google_storage_bucket.configs.name
  source = "${path.module}/files/jaeger-spark-dependencies-0.0.1-SNAPSHOT.jar"
}

