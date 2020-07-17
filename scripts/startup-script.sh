#! /bin/bash

sudo service stackdriver-agent start

if [[ `hostname` != clusternode* ]]; then
    sleep 60s && \
    export TOKEN=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"  -H "Metadata-Flavor: Google" | grep -Po '(?<="access_token":")([^"]*)') \
        VAULT_AGENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/vault-agent-config) \
        CONSUL_AGENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-config)
        CONSUL_CA=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-ca-file)
        CONSUL_CERT=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-cert-file)
        CONSUL_KEYFILE=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-keyfile-file)
    curl -o /etc/vault.d/agent.hcl -s -L -H "Authorization: Bearer $TOKEN" $VAULT_AGENT_CONFIG && \
    systemctl restart vault-agent
    curl -o /etc/consul.d/ca.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_CA && \
    curl -o /etc/consul.d/cert.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_CERT && \
    curl -o /etc/consul.d/keyfile.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_KEYFILE && \
    systemctl restart consul
fi
