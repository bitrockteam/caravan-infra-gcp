module "terraform-acme-le" {
  depends_on               = [module.caravan-bootstrap]
  source                   = "git::ssh://git@github.com/bitrockteam/caravan-acme-le?ref=main"
  gcp_project_id           = var.project_id
  gcp_service_account_file = var.google_account_file
  common_name              = concat([trimsuffix(google_dns_managed_zone.project-zone.dns_name, ".")], [google_dns_managed_zone.project-zone.id])[0]
  dns_provider             = "gcp"
  private_key              = tls_private_key.cert_private_key.private_key_pem
  dns_propagation_timeout  = "600"
  dns_polling_interval     = "20"
}

resource "null_resource" "ca_certs" {
  for_each = var.ca_certs
  provisioner "local-exec" {
    command = "curl -o ${each.value.filename} ${each.value.pemurl}"
  }
}

resource "null_resource" "ca_certs_bundle" {
  depends_on = [
    null_resource.ca_certs
  ]
  count = length(var.ca_certs)
  provisioner "local-exec" {
    command = "cat ${join(" ", [for k, v in var.ca_certs : v.filename])} > ca_certs.pem"
  }
}
