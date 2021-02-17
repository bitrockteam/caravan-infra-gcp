resource "google_compute_region_disk" "csi" {
  for_each = var.csi_volumes

  name   = each.key
  type   = lookup(each.value, "type", "pd-ssd")
  region = var.region
  size   = lookup(each.value, "size", 30)
  labels = merge(
    {
      platform = "nomad"
    },
    lookup(each.value, "tags", {})
  )
  replica_zones = lookup(each.value, "replica_zones", ["${var.region}-a", "${var.region}-b"])
}

locals {
  volumes_name_to_id = { for v in google_compute_region_disk.csi : v.name => v.id }
}
