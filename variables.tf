# GCP params
variable "region" {
  type = string
}
variable "zone" {
  type = string
}
variable "project_id" {
  type = string
}
variable "google_account_file" {
  type = string
}
variable "personal_ip_list" {
  type    = list(string)
  default = []
}
variable "cluster_instance_count" {
  type    = string
  default = "3"
}
variable "cluster_machine_type" {
  type    = string
  default = null
}
variable "default_machine_type" {
  type    = string
  default = "n2-standard-2"
}
variable "monitoring_machine_type" {
  type    = string
  default = "custom-2-10240-ext"
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
variable "base64" {
  type    = bool
  default = false
}
variable "gzip" {
  type    = bool
  default = false
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
variable "le_endpoint" {
  type    = string
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
variable "use_le_staging" {
  type = bool
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

# internal params
variable "ssh_user" {
  type    = string
  default = "centos"
}
variable "ssh_timeout" {
  type    = string
  default = "240s"
}
variable "image" {
  description = "Fully qualified image name"
  type = string
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

variable "control_plane_sa_name" {
  type = string
}

variable "worker_plane_sa_name" {
  type = string
}

variable "gcp_csi" {
  type = bool
}

variable "project_image_path" {
  type    = string
  default = ""
}

variable "envoy_proxy_image" {
  type    = string
  default = "envoyproxy/envoy:v1.14.2"
}

variable "admins" {
  default = [
    "user:michael.tabolsky@bitrock.it",
    "user:francesco.bartolini@bitrock.it",
    "user:matteo.gazzetta@bitrock.it",
  ]
}