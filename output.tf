output "cluster-public-ips" {
  value = {
    for n in google_compute_instance.hashicorp_cluster_nodes : n.name => n.network_interface.0.access_config.0.nat_ip
  }
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
output "worker_node_service_account" {
  value = [ for k,v in data.google_service_account.worker_node_service_account: v.email ]
}

output "PROJECT_PLATFORM_TFVAR" {
  value = templatefile("${path.module}/templates/platform-tfvar.tmpl",
    {
      project_id      = var.project_id,
      prefix          = var.prefix,
      external_domain = var.external_domain,
      region          = var.region,
      dc_name         = var.dc_name
  })
}

output "PROJECT_APPSUPP_TFVAR" {
  value = templatefile("${path.module}/templates/appsupp-tfvar.tmpl",
    {
      project_id      = var.project_id,
      prefix          = var.prefix,
      external_domain = var.external_domain,
      region          = var.region
      dc_name         = var.dc_name
  })
}

output "PROJECT_WORKLOAD_TFVAR" {
  value = templatefile("${path.module}/templates/workload-tfvar.tmpl",
    {
      project_id      = var.project_id,
      prefix          = var.prefix,
      external_domain = var.external_domain,
      region          = var.region
      dc_name         = var.dc_name
  })
}

output "ca_certs" {
  value = "${abspath(path.module)}/ca_certs.pem"
}
