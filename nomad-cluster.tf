module "nomad-cluster" {
  source                   = "git::ssh://git@github.com/bitrockteam/hcpoc-base-nomad-baseline//modules/nomad-cluster?ref=master"
  ssh_private_key          = chomp(tls_private_key.ssh-key.private_key_pem)
  cluster_nodes_ids        = google_compute_instance.hcpoc_cluster_nodes[*].instance_id
  cluster_nodes            = { for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.network_ip }
  cluster_nodes_public_ips = { for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip }
}
