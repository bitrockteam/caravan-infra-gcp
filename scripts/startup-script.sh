#! /bin/bash

sudo service stackdriver-agent start

if [[ `hostname` != clusternode* ]]; then
    sleep 100s && \
    export TOKEN=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"  -H "Metadata-Flavor: Google" | grep -Po '(?<="access_token":")([^"]*)') \
        VAULT_AGENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/vault-agent-config) \
        CONSUL_AGENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-config)
    curl -o /etc/vault.d/agent.hcl -s -L -H "Authorization: Bearer $TOKEN" $VAULT_AGENT_CONFIG && systemctl restart vault-agent
    curl -o /etc/consul.d/consul-agent.hcl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_AGENT_CONFIG && systemctl restart consul
fi
