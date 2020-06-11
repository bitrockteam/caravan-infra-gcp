variable "region" {}
variable "google_account_file" {}
variable "project_id" {}
variable "instance_count" {
  default = "3"
}
variable "prefix" {
  description = "The prefix of the objects' names"
  default     = "hcpoc-gcp"
}
variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.128.0.0/28"
}
