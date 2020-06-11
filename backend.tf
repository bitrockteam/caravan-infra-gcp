terraform {
  backend "gcs" {
    bucket = "hcpoc-gcp-storage"
    prefix = "terraform/state"
  }
}
