module "terraform-acme-le" {
  source              = "git::ssh://git@github.com/bitrockteam/hashicorp-terraform-acme-le?ref=master"
  project_id          = var.project_id
  google_account_file = var.google_account_file
  common_name         = "${var.prefix}.${var.external_domain}"
  dns_provider        = "gcloud"
  le_endpoint         = var.le_endpoint
  private_key         = tls_private_key.cert_private_key.private_key_pem
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
