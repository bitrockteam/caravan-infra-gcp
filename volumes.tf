resource "google_compute_region_disk" "jenkins_master" {
  count  = var.gcp_csi ? 1 : 0
  name   = "jenkins-master"
  type   = "pd-ssd"
  region = var.region
  size   = 30
  labels = {
    platform = "nomad",
    job      = "jenkins-master"
  }
  replica_zones = ["${var.region}-a", "${var.region}-b"]
}
