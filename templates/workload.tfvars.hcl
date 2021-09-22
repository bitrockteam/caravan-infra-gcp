
vault_endpoint          = "https://vault.${prefix}.${external_domain}"
consul_endpoint         = "https://consul.${prefix}.${external_domain}"
%{ if enable_nomad ~}
nomad_endpoint          = "https://nomad.${prefix}.${external_domain}"
%{ endif ~}
domain                  = "${prefix}.${external_domain}"
artifacts_source_prefix = "gcs::https://www.googleapis.com/storage/v1/cfgs-${project_id}"

%{ if use_le_staging ~}
vault_skip_tls_verify = true
consul_insecure_https = true
ca_cert_file          = "../caravan-infra-gcp/ca_certs.pem"
%{ else ~}
vault_skip_tls_verify = false
consul_insecure_https = false
%{ endif ~}

services_domain      = "service.consul"
dc_names             = ["${dc_name}"]
github_shared_secret = ""
github_token         = ""
