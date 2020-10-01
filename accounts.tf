data "google_client_openid_userinfo" "myself" {
}
resource "google_service_account" "cluster_node_service_account" {
  account_id   = "cluster-node"
  display_name = "Cluster Node Service Account"
  project      = var.project_id
}

resource "google_service_account" "worker_node_account" {
  for_each = {
    for template in keys(var.workers_instance_templates) :
    template => contains(keys(var.workers_instance_templates[template]), "user_account") ? var.workers_instance_templates[template].user_account : {}
  }
  account_id   = "wrknodeacc-${each.key}"
  display_name = "Worker Node Service Account for ${each.key}"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "key-account-iam" {
  service_account_id = google_service_account.cluster_node_service_account.id
  role               = "roles/iam.serviceAccountKeyAdmin"

  members = ["serviceAccount:${google_service_account.cluster_node_service_account.email}"]
}
resource "google_service_account_iam_binding" "key-account-iam-cluster" {
  service_account_id = google_service_account.cluster_node_service_account.id
  role               = "roles/iam.serviceAccountTokenCreator"

  members = ["serviceAccount:${google_service_account.cluster_node_service_account.email}"]
}

resource "google_service_account_iam_binding" "key-account-iam-workers" {
  for_each           = { for k, v in var.workers_instance_templates : "projects/${var.project_id}/serviceAccounts/wrknodeacc-${k}@${var.project_id}.iam.gserviceaccount.com" => "serviceAccount:wrknodeacc-${k}@${var.project_id}.iam.gserviceaccount.com" }
  service_account_id = each.key
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = [each.value, "serviceAccount:${google_service_account.cluster_node_service_account.email}"]
}

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


resource "google_service_account" "pd_csi_service_account" {
  account_id   = "pd-csi-sa"
  display_name = "Persistent Disk CSI Service Account"
  project      = var.project_id
}

resource "google_project_iam_custom_role" "gcp_compute_persistent_disk_csi_driver" {
  role_id     = "gcp_compute_persistent_disk_csi_driver_custom_role"
  title       = "Google Compute Engine Persistent Disk CSI Driver Custom Roles"
  description = "Custom roles required for functions of the gcp-compute-persistent-disk-csi-driver"
  permissions = ["compute.instances.get", "compute.instances.attachDisk", "compute.instances.detachDisk", "compute.disks.get"]
}

resource "google_project_iam_binding" "pd_csi_service_account_storage_admin_iam_binding" {
  project = var.project_id
  role               = "roles/compute.storageAdmin"

  members = ["serviceAccount:${google_service_account.pd_csi_service_account.email}"]
}

resource "google_service_account_iam_binding" "pd_csi_service_account_user_iam_binding" {
  service_account_id = google_service_account.pd_csi_service_account.id
  role               = "roles/iam.serviceAccountUser"

  members = ["serviceAccount:${google_service_account.pd_csi_service_account.email}"]
}

resource "google_service_account_iam_binding" "pd_csi_service_account_iam_binding" {
  depends_on = [google_project_iam_custom_role.gcp_compute_persistent_disk_csi_driver]

  service_account_id = google_service_account.pd_csi_service_account.id
  role               = "projects/${var.project_id}/roles/gcp_compute_persistent_disk_csi_driver_custom_role"

  members = ["serviceAccount:${google_service_account.pd_csi_service_account.email}"]
}
