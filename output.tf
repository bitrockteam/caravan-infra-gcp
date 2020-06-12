# output "private_ip-cluster-0" {
#   value = google_compute_instance.hcpoc_cluster_nodes.length >= 1 ? google_compute_instance.hcpoc_cluster_nodes[0].network_interface.0.access_config.0.nat_ip : null
# }
# output "private_ip-cluster-1" {
#   value = google_compute_instance.hcpoc_cluster_nodes.length >= 2 ? google_compute_instance.hcpoc_cluster_nodes[1].network_interface.0.access_config.0.nat_ip : null
# }
# output "private_ip-cluster-2" {
#   value = google_compute_instance.hcpoc_cluster_nodes.length >= 3 ? google_compute_instance.hcpoc_cluster_nodes[2].network_interface.0.access_config.0.nat_ip : null
# }
output "cluster-public-ips" {
  value = {
    for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip
  }
}
output "cluster-private-ips" {
  value = {
    for n in google_compute_instance.hcpoc_cluster_nodes : n.name => n.network_interface.0.network_ip
  }
}