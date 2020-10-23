# output "private_ip-cluster-0" {
#   value = google_compute_instance.hashicorp_cluster_nodes.length >= 1 ? google_compute_instance.hashicorp_cluster_nodes[0].network_interface.0.access_config.0.nat_ip : null
# }
# output "private_ip-cluster-1" {
#   value = google_compute_instance.hashicorp_cluster_nodes.length >= 2 ? google_compute_instance.hashicorp_cluster_nodes[1].network_interface.0.access_config.0.nat_ip : null
# }
# output "private_ip-cluster-2" {
#   value = google_compute_instance.hashicorp_cluster_nodes.length >= 3 ? google_compute_instance.hashicorp_cluster_nodes[2].network_interface.0.access_config.0.nat_ip : null
# }
output "cluster-public-ips" {
  value = {
    for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip
  }
}
output "cluster-private-ips" {
  value = {
    for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.network_ip
  }
}
output "configs-bucket-url" {
  value = google_storage_bucket.configs.url
}
output "worker_nodes_service_accounts" {
  value = [for k, v in data.google_service_account.worker_node_service_account : v.email]
}
output "load-balancer-ip-address" {
  value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
}
output "pd_ssd_jenkins_master_id" {
  value = var.gcp_csi ? google_compute_region_disk.jenkins_master[0].id : null
}
output "hashicorp_endpoints" {
  value = {
    vault  = "https://vault.${var.prefix}.${var.external_domain}"
    consul = "https://consul.${var.prefix}.${var.external_domain}"
    nomad  = "https://nomad.${var.prefix}.${var.external_domain}"
  }
}
