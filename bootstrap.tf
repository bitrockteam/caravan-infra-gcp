provider "google" {
  region      = var.region
  credentials = file(var.google_account_file)
}

module "packer_build" {
  source              = "git::ssh://git@github.com/bitrockteam/hcpoc-base-packer-centos?ref=master"
  build_on_google     = true
  google_project_id   = var.project_id
  google_account_file = var.google_account_file
}
