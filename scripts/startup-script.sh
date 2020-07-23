#! /bin/bash

sudo service stackdriver-agent start

if [[ `hostname` != clustnode* ]]; then
    sleep 60s && \
    export TOKEN=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"  -H "Metadata-Flavor: Google" | grep -Po '(?<="access_token":")([^"]*)') \
        VAULT_AGENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/vault-agent-config)
        NOMAD_AGENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-config)
        CONSUL_CA=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-ca-file)
        CONSUL_CERT=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-cert-file)
        CONSUL_KEYFILE=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-keyfile-file)
        NOMAD_CA=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad-agent-ca-file)
        NOMAD_CERT=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad-agent-cert-file)
        NOMAD_KEYFILE=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad-agent-keyfile-file)
        NOMAD_CLIENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad-client-config)
    curl -o /etc/vault.d/agent.hcl -s -L -H "Authorization: Bearer $TOKEN" $VAULT_AGENT_CONFIG && \
    curl -o /etc/consul.d/consul.hcl.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_AGENT_CONFIG && \
    curl -o /etc/consul.d/ca.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_CA && \
    curl -o /etc/consul.d/cert.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_CERT && \
    curl -o /etc/consul.d/keyfile.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_KEYFILE && \
    curl -o /etc/nomad.d/nomad.hcl -s -L -H "Authorization: Bearer $TOKEN" $NOMAD_CLIENT_CONFIG && \
    curl -o /etc/nomad.d/ca.tmpl -s -L -H "Authorization: Bearer $TOKEN" $NOMAD_CA && \
    curl -o /etc/nomad.d/cert.tmpl -s -L -H "Authorization: Bearer $TOKEN" $NOMAD_CERT && \
    curl -o /etc/nomad.d/keyfile.tmpl -s -L -H "Authorization: Bearer $TOKEN" $NOMAD_KEYFILE && \
    systemctl restart vault-agent && \
    systemctl restart consul && \
    systemctl restart nomad
fi
