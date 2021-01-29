module "vault_cluster" {
  source                   = "git::ssh://git@github.com/bitrockteam/hashicorp-vault-baseline//modules/cluster-raft?ref=master"
  cluster_nodes_ids        = google_compute_instance.hashicorp_cluster_nodes[*].instance_id
  cluster_nodes            = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  cluster_nodes_public_ips = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
  ssh_private_key          = tls_private_key.ssh-key.private_key_pem
  ssh_user                 = "centos"
  ssh_timeout              = "240s"
  unseal_type              = "gcp"
  unseal_region            = google_kms_key_ring.vault_keyring.location
  unseal_project_id        = var.project_id
  unseal_keyring           = google_kms_key_ring.vault_keyring.name
  unseal_key               = google_kms_crypto_key.vault_key.name
  gcp_node_role            = local.control_plane_role_name
  gcp_project_id           = var.project_id
  gcp_service_account      = data.google_service_account.control_plane_service_account.email
  prefix                   = var.prefix
}

module "vault_cluster_agents" {
  source              = "git::ssh://git@github.com/bitrockteam/hashicorp-vault-baseline//modules/agent?ref=feature/refactoring"
  vault_endpoint      = "http://127.0.0.1:8200"
  tcp_listener_tls    = false
  nodes_ids           = google_compute_instance.hashicorp_cluster_nodes[*].instance_id
  nodes               = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  nodes_public_ips    = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
  ssh_private_key     = tls_private_key.ssh-key.private_key_pem
  ssh_user            = "centos"
  ssh_timeout         = "240s"
  gcp_auto_auth       = true
  gcp_node_role       = local.control_plane_role_name
  gcp_project_id      = var.project_id
  gcp_service_account = data.google_service_account.control_plane_service_account.email
}

module "consul-cluster" {
  source                   = "git::ssh://git@github.com/bitrockteam/hashicorp-consul-baseline//modules/consul-cluster?ref=master"
  ssh_private_key          = tls_private_key.ssh-key.private_key_pem
  cluster_nodes_ids        = google_compute_instance.hashicorp_cluster_nodes[*].instance_id
  cluster_nodes            = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  cluster_nodes_public_ips = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
  vault_address            = module.vault_cluster.vault_address
  dc_name                  = var.dc_name
}

module "nomad-cluster" {
  depends_on = [
    module.vault_cluster,
    module.consul-cluster
  ]
  source                   = "git::ssh://git@github.com/bitrockteam/hashicorp-nomad-baseline//modules/nomad-cluster?ref=master"
  ssh_private_key          = tls_private_key.ssh-key.private_key_pem
  cluster_nodes_ids        = google_compute_instance.hashicorp_cluster_nodes[*].instance_id
  cluster_nodes            = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  cluster_nodes_public_ips = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
  dc_name                  = var.dc_name
  control_plane_vault_role = local.control_plane_role_name
}