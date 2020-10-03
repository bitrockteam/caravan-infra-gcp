resource "random_id" "keyring" {
  byte_length = 4
}

resource "google_kms_key_ring" "vault_keyring" {
  project  = var.project_id
  name     = "vault-keyring-${random_id.keyring.dec}"
  location = "global"
}

resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.vault_keyring.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.cluster_node_service_account.email}",
  ]
}

resource "google_kms_crypto_key" "vault_key" {
  name            = "vault-crypto-key-${var.project_id}"
  key_ring        = google_kms_key_ring.vault_keyring.self_link
  rotation_period = "1209660s"

}
