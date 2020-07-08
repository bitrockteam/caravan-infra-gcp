resource "google_storage_bucket" "configs" {
  name               = "cfgs-${var.project_id}"
  location           = var.location
  project            = var.project_id
  force_destroy      = true
  bucket_policy_only = true
  versioning {
    enabled = true
  }
}
#export TOKEN=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"  -H "Metadata-Flavor: Google" | grep -Po '(?<="access_token":")([^"]*)')
resource "google_storage_bucket_iam_binding" "configs_binding" {
  bucket = google_storage_bucket.configs.name
  role   = "roles/storage.objectViewer"
  members = concat([
    "serviceAccount:${google_service_account.cluster_node_service_account.email}",
    "serviceAccount:${data.google_client_openid_userinfo.myself.email}"
    ],
    [for k, v in google_service_account.worker_node_account : "serviceAccount:${v.email}"]
  )
}
