resource "google_dns_record_set" "a-hc" {
    name         = "gcp.${var.external_domain}."
    managed_zone = "${var.prefix}-zone"
    type         = "A"
    ttl          = 300

    rrdatas = [google_compute_global_forwarding_rule.global_forwarding_rule.ip_address] 
}

resource "google_dns_record_set" "cname-vault" {
    name         = "vault.${var.external_domain}."
    managed_zone = "${var.prefix}-zone"
    type         = "CNAME"
    ttl          = 30
    rrdatas      = ["${google_dns_record_set.a-hc.name}"]
}

resource "google_dns_record_set" "cname-consul" {
    name         = "consul.${var.external_domain}."
    managed_zone = "${var.prefix}-zone"
    type         = "CNAME"
    ttl          = 30
    rrdatas      = ["${google_dns_record_set.a-hc.name}"]
}
resource "google_dns_record_set" "cname-nomad" {
    name         = "nomad.${var.external_domain}."
    managed_zone = "${var.prefix}-zone"
    type         = "CNAME"
    ttl          = 30
    rrdatas      = ["${google_dns_record_set.a-hc.name}"]
}