locals {
  control_plane_role_name = "control-plane"
  worker_plane_role_name  = "worker-plane"
}

module "cloud_init_control_plane" {
  source              = "git::ssh://git@github.com/bitrockteam/hashicorp-terraform-cloudinit"
  cluster_nodes       = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  vault_endpoint      = "http://127.0.0.1:8200"
  dc_name             = var.dc_name
  auto_auth_type      = "gcp"
  gcp_node_role       = local.control_plane_role_name
  gcp_project_id      = var.project_id
  gcp_service_account = data.google_service_account.control_plane_service_account.email
  base64              = var.base64
  gzip                = var.gzip
}

module "cloud_init_worker_plane" {
  source              = "git::ssh://git@github.com/bitrockteam/hashicorp-terraform-cloudinit"
  cluster_nodes       = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  vault_endpoint      = "http://${google_compute_instance.hashicorp_cluster_nodes[0].network_interface.0.network_ip}:8200"
  dc_name             = var.dc_name
  auto_auth_type      = "gcp"
  gcp_node_role       = local.worker_plane_role_name
  gcp_project_id      = var.project_id
  gcp_service_account = data.google_service_account.worker_plane_service_account.email
  base64              = var.base64
  gzip                = var.gzip
}