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
