module "terraform-acme-le" {
  source              = "git::ssh://git@github.com/bitrockteam/hashicorp-terraform-acme-le?ref=master"
  project_id          = var.project_id
  google_account_file = var.google_account_file
  common_name         = "${var.prefix}.${var.external_domain}"
  dns_provider        = "gcloud"
  le_endpoint         = var.le_endpoint
  private_key         = tls_private_key.cert_private_key.private_key_pem
}