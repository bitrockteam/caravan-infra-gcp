resource "google_kms_key_ring" "vault_keyring" {
  project  = var.project_id
  name     = "vault-keyring"
  location = "global"
}

resource "google_kms_crypto_key" "vault_key" {
  name            = "vault-crypto-key"
  key_ring        = google_kms_key_ring.vault_keyring.id
  rotation_period = "1209660s"

  lifecycle {
    prevent_destroy = true
  }
}

