variable "region" {}
variable "zone" {}
variable "google_account_file" {}
variable "project_id" {}
variable "default_machine_type" {
  type    = string
  default = "n1-standard-2"
}
variable "cluster_instance_count" {
  default = "3"
}
variable "cluster_machine_type" {
  type    = string
  default = null
}
variable "prefix" {
  description = "The prefix of the objects' names"
  default     = "hcpoc-gcp"
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

variable "ssh_user" {
  type    = string
  default = "centos"
}
variable "ssh_timeout" {
  type    = string
  default = "240s"
}
variable "compute_image_name" {
  type    = string
  default = "hcpoc-centos-image"
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
      image_family_name = "hcpoc-centos-image"
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
