resource "google_dns_managed_zone" "project-zone" {
  project     = var.project_id
  name        = "${var.prefix}-zone"
  dns_name    = "${var.prefix}.${var.external_domain}."
  description = "DNS zone for cloud projects"
}

data "google_dns_managed_zone" "parent-zone" {
  project = var.parent_dns_project_id
  name    = var.parent_dns_zone_name
}

resource "google_dns_record_set" "projects-ns" {
  depends_on = [
    google_dns_managed_zone.project-zone
  ]

  project = var.parent_dns_project_id

  name         = "${var.prefix}.${var.external_domain}."
  managed_zone = data.google_dns_managed_zone.parent-zone.name
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.project-zone.name_servers
}

resource "google_dns_record_set" "a-hc" {
  name         = "gcp.${var.prefix}.${var.external_domain}."
  managed_zone = "${var.prefix}-zone"
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_forwarding_rule.global_forwarding_rule.ip_address]
}

resource "google_dns_record_set" "cname-vault" {
  depends_on = [
    google_dns_record_set.a-hc
  ]
  name         = "vault.${var.prefix}.${var.external_domain}."
  managed_zone = "${var.prefix}-zone"
  type         = "CNAME"
  ttl          = 30
  rrdatas      = [google_dns_record_set.a-hc.name]
}

resource "google_dns_record_set" "cname-consul" {
  depends_on = [
    google_dns_record_set.a-hc
  ]
  name         = "consul.${var.prefix}.${var.external_domain}."
  managed_zone = "${var.prefix}-zone"
  type         = "CNAME"
  ttl          = 30
  rrdatas      = [google_dns_record_set.a-hc.name]
}
resource "google_dns_record_set" "cname-nomad" {
  depends_on = [
    google_dns_record_set.a-hc
  ]
  name         = "nomad.${var.prefix}.${var.external_domain}."
  managed_zone = "${var.prefix}-zone"
  type         = "CNAME"
  ttl          = 30
  rrdatas      = [google_dns_record_set.a-hc.name]
}
resource "google_dns_record_set" "cname-wild" {
  depends_on = [
    google_dns_record_set.a-hc
  ]
  name         = "*.${var.prefix}.${var.external_domain}."
  managed_zone = "${var.prefix}-zone"
  type         = "CNAME"
  ttl          = 30
  rrdatas      = [google_dns_record_set.a-hc.name]
}
