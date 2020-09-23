#! /bin/bash

sudo service stackdriver-agent start

if [[ `hostname` != clustnode* ]]; then
    sleep 60s && \
    export TOKEN=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"  -H "Metadata-Flavor: Google" | grep -Po '(?<="access_token":")([^"]*)') \
        VAULT_AGENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/vault-agent-config)
        CONSUL_AGENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-config)
        CONSUL_CA=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-ca-file)
        CONSUL_CERT=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-cert-file)
        CONSUL_KEYFILE=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/consul-agent-keyfile-file)
        NOMAD_CA=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad-agent-ca-file)
        NOMAD_CERT=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad-agent-cert-file)
        NOMAD_KEYFILE=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad-agent-keyfile-file)
        NOMAD_CLIENT_CONFIG=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad-client-config)
        ELASTIC_SERVICE=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/elastic-service)
        GRAFANA_SERVICE=$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/grafana-service)
    curl -o /etc/vault.d/agent.hcl -s -L -H "Authorization: Bearer $TOKEN" $VAULT_AGENT_CONFIG && \
    curl -o /etc/consul.d/consul.hcl.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_AGENT_CONFIG && \
    curl -o /etc/consul.d/ca.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_CA && \
    curl -o /etc/consul.d/cert.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_CERT && \
    curl -o /etc/consul.d/keyfile.tmpl -s -L -H "Authorization: Bearer $TOKEN" $CONSUL_KEYFILE && \
    curl -o /etc/nomad.d/nomad_ca.tmpl -s -L -H "Authorization: Bearer $TOKEN" $NOMAD_CA && \
    curl -o /etc/nomad.d/nomad_cert.tmpl -s -L -H "Authorization: Bearer $TOKEN" $NOMAD_CERT && \
    curl -o /etc/nomad.d/nomad_keyfile.tmpl -s -L -H "Authorization: Bearer $TOKEN" $NOMAD_KEYFILE && \
    curl -o /etc/nomad.d/nomad.hcl.tmpl -s -L -H "Authorization: Bearer $TOKEN" $NOMAD_CLIENT_CONFIG && \
    curl -o /etc/consul.d/elastic-service.json -s -L -H "Authorization: Bearer $TOKEN" $ELASTIC_SERVICE && \
    curl -o /etc/consul.d/grafana-service.json -s -L -H "Authorization: Bearer $TOKEN" $GRAFANA_SERVICE && \
    systemctl restart vault-agent && \
    systemctl restart consul && \
    systemctl restart nomad
fi

sudo sysctl -w vm.max_map_count=262144

sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
