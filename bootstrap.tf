module "hashicorp-bootstrap" {
  source                   = "git::ssh://git@github.com/bitrockteam/hashicorp-terraform-bootstrap?ref=main"
  cluster_nodes_ids        = google_compute_instance.hashicorp_cluster_nodes[*].instance_id
  cluster_nodes            = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  cluster_nodes_public_ips = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
  nodes                    = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip }
  nodes_ids                = google_compute_instance.hashicorp_cluster_nodes[*].instance_id
  nodes_public_ips         = { for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
  ssh_private_key          = chomp(tls_private_key.ssh-key.private_key_pem)
  ssh_user                 = var.ssh_user
  ssh_timeout              = var.ssh_timeout
  gcp_project_id           = var.project_id
  gcp_node_role            = "cluster-node"
  gcp_service_account      = "cluster-node@${var.project_id}.iam.gserviceaccount.com"
  gcp_auto_auth            = true
  unseal_project_id        = var.project_id
  unseal_keyring           = google_kms_key_ring.vault_keyring.name
  unseal_key               = google_kms_crypto_key.vault_key.name
  vault_endpoint           = "http://127.0.0.1:8200"
  tcp_listener_tls         = false
  dc_name                  = var.dc_name
}
