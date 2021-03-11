
vault_endpoint = "https://vault.${prefix}.${external_domain}"
consul_endpoint = "https://consul.${prefix}.${external_domain}"
nomad_endpoint = "https://nomad.${prefix}.${external_domain}"

%{ if use_le_staging ~}
vault_skip_tls_verify = true
consul_insecure_https = true
ca_cert_file          = "../caravan-infra-gcp/ca_certs.pem"
%{ else ~}
vault_skip_tls_verify = false
consul_insecure_https = false
%{ endif ~}

bootstrap_state_backend_provider = "gcp"
auth_providers                   = ["gcp", "gsuite"]
gcp_project_id                   = "${project_id}"
gcp_csi                          = true
gcp_region                       = "${region}"
google_account_file              = "../caravan-infra-gcp/.${project_id}-key.json"

gsuite_domain                = ""
gsuite_client_id             = ""
gsuite_client_secret         = ""
gsuite_default_role          = "bitrock"
gsuite_default_role_policies = [ "default", "bitrock", "vault-admin-role" ]
gsuite_allowed_redirect_uris = [ "https://vault.${prefix}.${external_domain}/ui/vault/auth/gsuite/oidc/callback", "https://vault.${prefix}.${external_domain}/ui/vault/auth/oidc/oidc/callback"]

bootstrap_state_bucket_name_prefix = "states-bucket"
bootstrap_state_object_name_prefix = "infraboot/terraform/state"
control_plane_role_name            = "control-plane"
