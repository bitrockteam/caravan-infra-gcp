# GCP params
variable "google_account_file" {
  type        = string
  description = "Path to Google account file"
}
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region where to deploy the cluster"
}
variable "zone" {
  type        = string
  description = "GCP zone"
}
variable "allowed_ip_list" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "IP address list for SSH connection to the VMs"
}

# GCP Network
variable "subnet_prefix" {
  default     = "10.128.0.0/28"
  description = "The address prefix to use for the subnet"
}
variable "parent_dns_zone_name" {
  type        = string
  default     = "GCP"
  description = "GCP parent project DNS zone name"
}
variable "parent_dns_project_id" {
  type        = string
  default     = ""
  description = "GCP parent project ID"
}
variable "google_kms_key_ring" {
  type        = string
  default     = ""
  description = "GCP KMS key ring"
}
variable "google_kms_crypto_key" {
  type        = string
  default     = ""
  description = "GCP KMS crypto key"
}

# GCP Compute
variable "control_plane_instance_count" {
  type        = string
  default     = "3"
  description = "Control plane instances number"
}
variable "control_plane_machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "Control plane instance machine type"
}
variable "worker_plane_machine_type" {
  type        = string
  default     = "n2-standard-2"
  description = "Worker plane instance machine type"
}
variable "preemptible_instance_type" {
  type        = bool
  default     = false
  description = "Sets preemptible instance type"
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
  description = "Worker instance template map"
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
  description = "Worker instance group map"
}
variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enables and setup monitoring node"
}
variable "base64" {
  type        = bool
  default     = false
  description = "Cloud init decoding"
}
variable "gzip" {
  type        = bool
  default     = false
  description = "Cloud init compressing"
}
variable "image" {
  type        = string
  description = "Fully qualified image name"
}

# Hashicorp params
variable "dc_name" {
  type    = string
  default = "gcp-dc"
  validation {
    condition     = can(regex("^([a-z0-9]+(-[a-z0-9]+)*)+$", var.dc_name))
    error_message = "Invalid dc_name. Must contain letters, numbers and hyphen."
  }
  description = "Hashicorp cluster name"
}
variable "prefix" {
  default     = ""
  description = "The prefix of the objects' names"
}
variable "external_domain" {
  type        = string
  default     = ""
  description = "Domain used for endpoints and certs"
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
  description = "Fake certificates from staging Let's Encrypt"
}
variable "control_plane_sa_name" {
  type        = string
  default     = "control-plane"
  description = "Control plane service account name, it will be used by Vault Auth method"
}
variable "worker_plane_sa_name" {
  type        = string
  default     = "worker-plane"
  description = "Worker plane service account name, it will be used by Vault Auth method"
}
variable "csi_volumes" {
  type        = map(map(string))
  default     = {}
  description = <<EOF
Example:
{
  "jenkins" : {
    "type" : "pd-ssd"
    "size" : "30"
    "replica_zones" : ["us-central1-a", "us-central1-b"]
    "tags" : { "application": "jenkins_master" }
  }
}
EOF
}

# Common
variable "ssh_user" {
  type        = string
  default     = "centos"
  description = "SSH user"
}
variable "ssh_timeout" {
  type        = string
  default     = "240s"
  description = "SSH timeout"
}
variable "admins" {
  type        = list(string)
  default     = []
  description = "List of admins to add to the project"
}
variable "use_le_staging" {
  type        = bool
  default     = false
  description = "Use staging Let's Encrypt endpoint"
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

variable "vault_license_file" {
  type        = string
  default     = null
  description = "Path to Vault Enterprise license"
}
variable "consul_license_file" {
  type        = string
  default     = null
  description = "Path to Consul Enterprise license"
}
variable "nomad_license_file" {
  type        = string
  default     = null
  description = "Path to Nomad Enterprise license"
}
