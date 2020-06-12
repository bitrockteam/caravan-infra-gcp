resource "google_kms_key_ring" "vault_keyring" {
  project  = var.project_id
  name     = "vault-keyring"
  location = "global"
}

resource "google_service_account" "cluster_node_service_account" {
  account_id   = "cluster-node"
  display_name = "Cluster Node Service Account"
  project      = var.project_id
}

resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.vault_keyring.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.cluster_node_service_account.email}",
  ]
}

resource "google_kms_crypto_key" "vault_key" {
  name            = "vault-crypto-key"
  key_ring        = google_kms_key_ring.vault_keyring.id
  rotation_period = "1209660s"

  lifecycle {
    prevent_destroy = true
  }
}
