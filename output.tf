output "cluster-public-ips" {
  value = {
    for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip
  }
  description = "Control plane public IP addresses"
}
output "load-balancer-ip-address" {
  value       = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
  description = "Load Balancer IP address"
}
output "hashicorp_endpoints" {
  value = {
    vault  = "https://vault.${var.prefix}.${var.external_domain}"
    consul = "https://consul.${var.prefix}.${var.external_domain}"
    nomad  = "https://nomad.${var.prefix}.${var.external_domain}"
  }
  description = "Hashicorp clusters endpoints"
}
output "worker_plane_service_account" {
  value       = [google_service_account.worker_plane_service_account.email]
  description = "Worker plane service account"
}
output "PROJECT_PLATFORM_TFVAR" {
  value       = local.tfvars_platform
  description = "Caravan Platform tfvars"
}

output "PROJECT_APPSUPP_TFVAR" {
  value       = local.tfvars_appsupport
  description = "Caravan Application Support tfvars"
}

output "PROJECT_WORKLOAD_TFVAR" {
  value       = local.tfvars_workload
  description = "Caravan Workload tfvars"
}
output "ca_certs" {
  value       = "${abspath(path.module)}/ca_certs.pem"
  description = "Let's Encrypt staging CA certificates"
}
output "control_plane_role_name" {
  value       = local.control_plane_role_name
  description = "Control plane role name"
}
output "worker_plane_role_name" {
  value       = local.worker_plane_role_name
  description = "Worker plane role name"
}
output "control_plane_service_accounts" {
  value       = [google_service_account.control_plane_service_account.email]
  description = "Control plane service accounts email list"
}
output "worker_plane_service_accounts" {
  value       = [google_service_account.worker_plane_service_account.email]
  description = "Worker plane service accounts email list"
}
output "project_id" {
  value       = var.project_id
  description = "GCP project ID"
}
output "csi_volumes" {
  value = local.volumes_name_to_id
}
