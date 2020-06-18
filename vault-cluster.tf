module "vault_cluster" {
  source                   = "git::ssh://git@github.com/bitrockteam/hcpoc-base-vault-baseline//modules/cluster-raft?ref=master"
  unseal_project_id        = var.project_id
  unseal_keyring           = google_kms_key_ring.vault_keyring.name
  unseal_key               = google_kms_crypto_key.vault_key.name
  cluster_nodes            = { for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.network_ip }
  cluster_nodes_public_ips = { for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
  ssh_private_key          = chomp(tls_private_key.ssh-key.private_key_pem)
  ssh_user                 = var.ssh_user
  ssh_timeout              = var.ssh_timeout
}

provider "vault" {
  address = "https://${module.vault_cluster.vault_endpoint}:8200"
}

resource "vault_mount" "consul" {
  depends_on = [
    null_resource.vault_cluster_node_1_init,
  ]
  path        = "consul"
  type        = "consul"
  description = "Enable Consul secrets engine"
}

resource "vault_mount" "userpass" {
  depends_on = [
    null_resource.vault_cluster_node_1_init,
  ]
  path        = "userpass"
  type        = "userpass"
  description = "Enable UserPass auth method"
}

resource "vault_mount" "approle" {
  depends_on = [
    null_resource.vault_cluster_node_1_init,
  ]
  path        = "approle"
  type        = "approle"
  description = "Enable AppRole auth method"
}

resource "vault_mount" "GCP_secrets" {
  depends_on = [
    null_resource.vault_cluster_node_1_init,
  ]
  path        = "GCP"
  type        = "GCP"
  description = "Enable GCP secrets engine"
}