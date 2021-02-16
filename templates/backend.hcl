
terraform {
  backend "gcs" {
    bucket = "states-bucket-${project_id}"
    prefix = "${key}/terraform/state"
    credentials = "../caravan-infra-gcp/.${project_id}-key.json"
  }
}
