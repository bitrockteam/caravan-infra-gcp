module "hashicorp-bootstrap" {
  source                   = "git::ssh://git@github.com/bitrockteam/hashicorp-terraform-bootstrap?ref=main"
  ssh_private_key          = chomp(tls_private_key.ssh-key.private_key_pem)
  ssh_user                 = var.ssh_user
  ssh_timeout              = var.ssh_timeout
  prefix                   = var.prefix
  dc_name                  = var.dc_name
  tcp_listener_tls         = false
  control_plane_nodes_ids                = google_compute_instance.hashicorp_cluster_nodes[*].instance_id
  control_plane_nodes                    = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  control_plane_nodes_public_ips         = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
  agent_auto_auth_type     = "gcp"
  unseal_type              = "gcp"
  gcp_project_id           = var.project_id
  gcp_service_account      = google_service_account.control_plane_service_account.email
  gcp_node_role            = local.control_plane_role_name
  gcp_keyring           = google_kms_key_ring.vault_keyring.name
  gcp_region            = google_kms_key_ring.vault_keyring.location
  gcp_key               = google_kms_crypto_key.vault_key.name
  vault_endpoint           = "http://127.0.0.1:8200"
  control_plane_role_name  = local.control_plane_role_name
}
