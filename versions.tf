terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
    }
    google = {
      source = "hashicorp/google"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = "~> 0.13.6"
}
