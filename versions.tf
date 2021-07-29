terraform {
  required_providers {
    acme = {
      source = "vancluever/acme"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 3.0"
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
  required_version = "~> 0.15.4"
}
