data "google_client_openid_userinfo" "myself" {
}

data "google_project" "project" {
}


resource "google_service_account" "control_plane_service_account" {
  project      = var.project_id
  account_id   = var.control_plane_sa_name
  display_name = "Control plane service account"
}

resource "google_service_account" "worker_plane_service_account" {
  project      = var.project_id
  account_id   = var.worker_plane_sa_name
  display_name = "Worker plane service account"
}

resource "google_project_iam_member" "project" {
  count   = length(var.admins)
  project = var.project_id
  role    = "roles/owner"

  member = var.admins[count.index]
}

resource "google_service_account_iam_binding" "key_account_iam" {
  service_account_id = google_service_account.control_plane_service_account.id
  role               = "roles/iam.serviceAccountKeyAdmin"

  members = ["serviceAccount:${google_service_account.control_plane_service_account.email}"]
}
resource "google_service_account_iam_binding" "key_account_iam_control_plane" {
  service_account_id = google_service_account.control_plane_service_account.id
  role               = "roles/iam.serviceAccountTokenCreator"

  members = ["serviceAccount:${google_service_account.control_plane_service_account.email}"]
}

resource "google_service_account_iam_binding" "key_account_iam_workers" {
  service_account_id = google_service_account.worker_plane_service_account.id
  role               = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:${google_service_account.control_plane_service_account.email}",
    "serviceAccount:${google_service_account.worker_plane_service_account.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "configs_binding" {
  bucket = google_storage_bucket.configs.name
  role   = "roles/storage.objectViewer"
  members = concat([
    "serviceAccount:${google_service_account.control_plane_service_account.email}",
    "serviceAccount:${data.google_client_openid_userinfo.myself.email}",
    "serviceAccount:${google_service_account.worker_plane_service_account.email}"]
  )
}

resource "random_id" "random" {
  byte_length = 4
}

resource "google_service_account" "pd_csi_service_account" {
  account_id   = "pd-csi-sa-${replace(var.project_id, "/(-[0-9]+)/", "")}"
  display_name = "Persistent Disk CSI Service Account for ${var.project_id}"
  project      = var.project_id
}

resource "google_project_iam_custom_role" "gcp_compute_persistent_disk_csi_driver" {
  role_id     = "pd_csi_custom_role_${google_service_account.pd_csi_service_account.unique_id}"
  title       = "Google Compute Engine Persistent Disk CSI Driver Custom Roles for ${var.project_id}"
  description = "Custom roles required for functions of the gcp-compute-persistent-disk-csi-driver"
  permissions = ["compute.instances.get", "compute.instances.attachDisk", "compute.instances.detachDisk", "compute.disks.get"]
}

resource "google_project_iam_binding" "pd_csi_service_account_storage_admin_iam_binding" {
  project = var.project_id
  role    = "roles/compute.storageAdmin"

  members = ["serviceAccount:${google_service_account.pd_csi_service_account.email}"]
}

resource "google_project_iam_binding" "pd_csi_service_account_user_iam_binding" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"

  members = ["serviceAccount:${google_service_account.pd_csi_service_account.email}"]
}

resource "google_project_iam_binding" "pd_csi_service_account_iam_binding" {
  depends_on = [google_project_iam_custom_role.gcp_compute_persistent_disk_csi_driver]

  project = var.project_id
  role    = "projects/${var.project_id}/roles/pd_csi_custom_role_${google_service_account.pd_csi_service_account.unique_id}"

  members = ["serviceAccount:${google_service_account.pd_csi_service_account.email}"]
}

resource "google_service_account_key" "pd_csi_sa_key" {
  service_account_id = google_service_account.pd_csi_service_account.account_id
}
