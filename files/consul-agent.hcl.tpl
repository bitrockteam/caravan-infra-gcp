datacenter = "hcpoc"
data_dir = "/var/lib/consul"
log_level = "INFO"
retry_join = [
   %{ for n in keys("${cluster_nodes}") ~}
   "${cluster_nodes[n]}:8301",
   %{ endfor ~}
]
telemetry = {
   statsite_address = "127.0.0.1:2180"
}
acl {
   enabled = true
   default_policy = "deny"
   enable_token_persistence = true
 }
ui = true
client_addr = "0.0.0.0"
connect {
   enabled = true
#   ca_provider = "vault"
#   ca_config {
#        address = "http://localhost:8200"
#        token = "..."
#        root_pki_path = "pki"
#        intermediate_pki_path = "pki-connect"
#    }
}
#verify_incoming = true
#verify_outgoing = true
#verify_server_hostname = true
