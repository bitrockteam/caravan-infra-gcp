output "private_ip-worker-0" {
  value = google_compute_instance.hcpoc_workers[0].network_interface.0.access_config.0.nat_ip
}
output "private_ip-worker-1" {
  value = google_compute_instance.hcpoc_workers[1].network_interface.0.access_config.0.nat_ip
}
output "private_ip-worker-2" {
  value = google_compute_instance.hcpoc_workers[2].network_interface.0.access_config.0.nat_ip
}