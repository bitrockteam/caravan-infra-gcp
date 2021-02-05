# GCP params
variable "google_account_file" {
  type = string
}
variable "project_id" {
  type = string
}
variable "region" {
  type    = string
  default = "us-central1"
}
variable "zone" {
  type = string
}
variable "allowed_ip_list" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# GCP Network
variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.128.0.0/28"
}
variable "parent_dns_zone_name" {
  type    = string
  default = ""
}
variable "parent_dns_project_id" {
  type    = string
  default = ""
}
variable "google_kms_key_ring" {
  type    = string
  default = ""
}
variable "google_kms_crypto_key" {
  type    = string
  default = ""
}

# GCP Compute
variable "control_plane_instance_count" {
  type    = string
  default = "3"
}
variable "control_plane_machine_type" {
  type    = string
  default = "e2-standard-2"
}
variable "worker_plane_machine_type" {
  type    = string
  default = "n2-standard-2"
}
variable "preemptible_instance_type" {
  type    = bool
  default = false
}
variable "workers_instance_templates" {
  type = map(any)
  default = {
    worker-template = {
      name_prefix       = "worker-template-default-"
      machine_type      = "n1-standard-2"
      image_family_name = "centos-image"
      preemptible       = false
    }
  }
}
variable "workers_groups" {
  type = map(any)
  default = {
    workers-group = {
      base_instance_name = "worker"
      zone               = "us-central1-a"
      target_size        = 3
      instance_template  = "worker-template"
    }
  }
}
variable "base64" {
  type    = bool
  default = false
}
variable "gzip" {
  type    = bool
  default = false
}
variable "image" {
  description = "Fully qualified image name"
  type        = string
}

# Hashicorp params
variable "dc_name" {
  type    = string
  default = "gcp-dc"
  validation {
    condition     = can(regex("^([a-z0-9]+(-[a-z0-9]+)*)+$", var.dc_name))
    error_message = "Invalid dc_name. Must contain letters, numbers and hyphen."
  }
}
variable "prefix" {
  description = "The prefix of the objects' names"
  default     = ""
}
variable "external_domain" {
  type    = string
  default = ""
}
variable "ca_certs" {
  type = map(object({
    filename = string
    pemurl   = string
  }))
  default = {
    fakeleintermediatex1 = {
      filename = "fakeleintermediatex1.pem"
      pemurl   = "https://letsencrypt.org/certs/fakeleintermediatex1.pem"
    },
    fakelerootx1 = {
      filename = "fakelerootx1.pem"
      pemurl   = "https://letsencrypt.org/certs/fakelerootx1.pem"
    }
  }
}
variable "control_plane_sa_name" {
  type    = string
  default = "control-plane"
}
variable "worker_plane_sa_name" {
  type    = string
  default = "worker-plane"
}
variable "gcp_csi" {
  type    = bool
  default = true
}

# Common
variable "ssh_user" {
  type    = string
  default = "centos"
}
variable "ssh_timeout" {
  type    = string
  default = "240s"
}
variable "admins" {
  type = list(string)
  default = []
}
variable "use_le_staging" {
  type = bool
  default = false
}
variable "le_staging_endpoint" {
  type        = string
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
  description = "LE's endpoint when use_le_staging==true"
}
variable "le_production_endpoint" {
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
  description = "LE's endpoint when use_le_staging==false"
}
