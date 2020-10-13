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
  rrdatas      = ["${google_dns_record_set.a-hc.name}"]
}

resource "google_dns_record_set" "cname-consul" {
  depends_on = [
    google_dns_record_set.a-hc
  ]
  name         = "consul.${var.prefix}.${var.external_domain}."
  managed_zone = "${var.prefix}-zone"
  type         = "CNAME"
  ttl          = 30
  rrdatas      = ["${google_dns_record_set.a-hc.name}"]
}
resource "google_dns_record_set" "cname-nomad" {
  depends_on = [
    google_dns_record_set.a-hc
  ]
  name         = "nomad.${var.prefix}.${var.external_domain}."
  managed_zone = "${var.prefix}-zone"
  type         = "CNAME"
  ttl          = 30
  rrdatas      = ["${google_dns_record_set.a-hc.name}"]
}
resource "google_dns_record_set" "cname-wild" {
  depends_on = [
    google_dns_record_set.a-hc
  ]
  name         = "*.${var.prefix}.${var.external_domain}."
  managed_zone = "${var.prefix}-zone"
  type         = "CNAME"
  ttl          = 30
  rrdatas      = ["${google_dns_record_set.a-hc.name}"]
}
