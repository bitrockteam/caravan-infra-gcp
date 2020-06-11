output "private_ip-cluster-0" {
  value = google_compute_instance.hcpoc_cluster_nodes[0].network_interface.0.access_config.0.nat_ip
}
output "private_ip-cluster-1" {
  value = google_compute_instance.hcpoc_cluster_nodes[1].network_interface.0.access_config.0.nat_ip
}
output "private_ip-cluster-2" {
  value = google_compute_instance.hcpoc_cluster_nodes[2].network_interface.0.access_config.0.nat_ip
}
