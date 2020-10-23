# GCP params
variable "region" {}
variable "zone" {}
variable "google_account_file" {}
variable "project_id" {}
variable "default_machine_type" {
  type    = string
  default = "n2-standard-2"
}
variable "cluster_instance_count" {
  default = "3"
}
variable "cluster_machine_type" {
  type    = string
  default = null
}
variable "monitoring_machine_type" {
  type    = string
  default = "n2-standard-2"
}
variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.128.0.0/28"
}
variable "google_kms_key_ring" {
  type    = string
  default = ""
}
variable "google_kms_crypto_key" {
  type    = string
  default = ""
}
# Hashicorp params
variable "dc_name" {
  type = string
}
variable "prefix" {
  description = "The prefix of the objects' names"
  default     = ""
}
variable "external_domain" {
  type    = string
  default = ""
}
variable "le_endpoint" {
  type    = string
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

# internal params
variable "ssh_user" {
  type    = string
  default = "centos"
}
variable "ssh_timeout" {
  type    = string
  default = "240s"
}
variable "compute_image_prefix" {
  description = "Override the default var.prefix before the var.compute_image_name"
  default     = null
}
variable "compute_image_name" {
  type    = string
  default = "centos-image"
}
variable "skip_packer_build" {
  type    = bool
  default = false
}
variable "workers_instance_templates" {
  type = map(any)
  default = {
    def-wrkr = {
      name_prefix       = "worker-template-default-"
      machine_type      = "n1-standard-2"
      image_family_name = "centos-image"
      preemptible       = true
    }
  }
}
variable "workers_groups" {
  type = map(any)
  default = {
    def-wrkr-grp = {
      base_instance_name = "defwrkr"
      zone               = "us-central1-a"
      target_size        = 3
      instance_template  = "def-wrkr"
    }
  }
}

variable "preemptible_cluster_node" {
  type    = bool
  default = true
}

variable "preemptible_monitoring_node" {
  type    = bool
  default = true
}

variable "cluster_node_sa" {
  type = string
}

variable "worker_node_sa" {
  type = string
}

variable "gcp_csi" {
  type = bool
}

variable "project_image_path" {
  type    = string
  default = ""
}
