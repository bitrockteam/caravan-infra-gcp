locals {
  tfvars_platform = templatefile("${path.module}/templates/platform.tfvars.hcl", {
    project_id      = var.project_id,
    prefix          = var.prefix,
    external_domain = var.external_domain,
    region          = var.region,
    dc_name         = var.dc_name
    use_le_staging  = var.use_le_staging
  })
  backend_tf_platform = templatefile("${path.module}/templates/backend.hcl", {
    key        = "platform"
    project_id = var.project_id
  })

  tfvars_appsupport = templatefile("${path.module}/templates/appsupport.tfvars.hcl", {
    project_id        = var.project_id,
    prefix            = var.prefix,
    external_domain   = var.external_domain,
    region            = var.region
    dc_name           = var.dc_name
    use_le_staging    = var.use_le_staging
    jenkins_volume_id = var.gcp_csi ? google_compute_region_disk.jenkins_master[0].id : ""
  })
  backend_tf_appsupport = templatefile("${path.module}/templates/backend.hcl", {
    key        = "appsupport"
    project_id = var.project_id
  })

  tfvars_workload = templatefile("${path.module}/templates/workload.tfvars.hcl", {
    project_id      = var.project_id,
    prefix          = var.prefix,
    external_domain = var.external_domain,
    region          = var.region
    dc_name         = var.dc_name
    use_le_staging  = var.use_le_staging
  })
  backend_tf_workload = templatefile("${path.module}/templates/backend.hcl", {
    key        = "workload"
    project_id = var.project_id
  })
}

resource "local_file" "tfvars_platform" {
  filename = "${path.module}/../caravan-platform/${var.prefix}-gcp.tfvars"
  content  = local.tfvars_platform
}
resource "local_file" "backend_tf_platform" {
  filename = "${path.module}/../caravan-platform/${var.prefix}-gcp-backend.tf.bak"
  content  = local.backend_tf_platform
}

resource "local_file" "tfvars_appsupport" {
  filename = "${path.module}/../caravan-application-support/${var.prefix}-gcp.tfvars"
  content  = local.tfvars_appsupport
}
resource "local_file" "backend_tf_appsupport" {
  filename = "${path.module}/../caravan-application-support/${var.prefix}-gcp-backend.tf.bak"
  content  = local.backend_tf_appsupport
}

resource "local_file" "tfvars_workload" {
  filename = "${path.module}/../caravan-workload/${var.prefix}-gcp.tfvars"
  content  = local.tfvars_workload
}
resource "local_file" "backend_tf_workload" {
  filename = "${path.module}/../caravan-workload/${var.prefix}-gcp-backend.tf.bak"
  content  = local.backend_tf_workload
}
