terraform {
  backend "gcs" {
    bucket = "terraform-remote-backend"
    prefix = "terraform/state"
  }
}
