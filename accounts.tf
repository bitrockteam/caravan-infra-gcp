data "google_client_openid_userinfo" "myself" {
}

data "google_service_account" "cluster_node_service_account" {
  account_id = var.cluster_node_sa
}

data "google_service_account" "worker_node_service_account" {
  for_each = var.workers_instance_templates
  account_id = "${var.worker_node_sa}-${each.key}"
}

resource "google_service_account_iam_binding" "key-account-iam" {
  service_account_id = data.google_service_account.cluster_node_service_account.id
  role               = "roles/iam.serviceAccountKeyAdmin"

  members = ["serviceAccount:${data.google_service_account.cluster_node_service_account.email}"]
}
resource "google_service_account_iam_binding" "key-account-iam-cluster" {
  service_account_id = data.google_service_account.cluster_node_service_account.id
  role               = "roles/iam.serviceAccountTokenCreator"

  members = ["serviceAccount:${data.google_service_account.cluster_node_service_account.email}"]
}

resource "google_service_account_iam_binding" "key-account-iam-workers" {
  for_each           = { for k, v in var.workers_instance_templates : "projects/${var.project_id}/serviceAccounts/wrknodeacc-${k}@${var.project_id}.iam.gserviceaccount.com" => "serviceAccount:wrknodeacc-${k}@${var.project_id}.iam.gserviceaccount.com" }
  service_account_id = each.key
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = [each.value, "serviceAccount:${data.google_service_account.cluster_node_service_account.email}"]
}

resource "google_storage_bucket_iam_binding" "configs_binding" {
  bucket = google_storage_bucket.configs.name
  role   = "roles/storage.objectViewer"
  members = concat([
    "serviceAccount:${data.google_service_account.cluster_node_service_account.email}",
    "serviceAccount:${data.google_client_openid_userinfo.myself.email}"
    ],
    [for k, v in data.google_service_account.worker_node_service_account : "serviceAccount:${v.email}"]
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
