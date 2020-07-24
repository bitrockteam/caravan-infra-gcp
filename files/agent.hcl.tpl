exit_after_auth = false
pid_file = "/var/lib/vault/agent.pid"

cache {
  use_auto_auth_token = true
}

listener "tcp" {
  address = "${tcp_listener}"
  tls_disable = ${!tcp_listener_tls}
}

vault {
  tls_disable = true
  address     = "${vault_endpoint}"
}
auto_auth {
  method "gcp" {
    config = {
       type="iam"
       role="${gcp_node_role}"
       service_account="${gcp_service_account}"
       project="${gcp_project_id}"
    }
  }
  sink {
    type = "file"
    config = {
      path = "/etc/consul.d/vault_token"
    }
  }
}


template {
  source      = "/etc/consul.d/cert.tmpl"
  destination = "/etc/consul.d/cert"
}
template {
  source      = "/etc/consul.d/keyfile.tmpl"
  destination = "/etc/consul.d/keyfile"
}
template {
  source      = "/etc/consul.d/ca.tmpl"
  destination = "/etc/consul.d/ca"
}

template {
  source      = "/etc/consul.d/consul.hcl.tmpl"
  destination = "/etc/consul.d/consul.hcl"
  backup      = true
  error_on_missing_key = true
}

template {
  source      = "/etc/nomad.d/nomad.hcl.tmpl"
  destination = "/etc/nomad.d/nomad.hcl"
  backup      = true
  error_on_missing_key = true
}