#! /bin/bash

set -e

BILLING_ACCOUNT_ID=$1
ORG_ID=$2
PARENT_PROJECT_ID=$3
PROJECT_ID=$4
PROJECT_NAME=$5
REGION=$6

CLOUD_NAME=gcp
PREFIX=$PROJECT_NAME

echo -e "\033[32mCreating ${PROJECT_ID}, named ${PROJECT_NAME} in ${REGION}...\033[0m"
gcloud projects create ${PROJECT_ID} --name=${PROJECT_NAME} --organization=${ORG_ID}
gcloud config set project ${PROJECT_ID}
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=user:$(gcloud config list --format=json | jq -r ".core.account") --role=roles/owner
gcloud beta billing projects link ${PROJECT_ID} --billing-account ${BILLING_ACCOUNT_ID}

echo -e "\033[32mEnable some GCP services...\033[0m"
gcloud services enable compute.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    serviceusage.googleapis.com \
    cloudkms.googleapis.com \
    iam.googleapis.com \
    cloudresourcemanager.googleapis.com \
    dns.googleapis.com

echo -e "\033[32mCreate terraform state bucket...\033[0m"
gsutil mb -b off -c standard -l ${REGION} -p ${PROJECT_ID} gs://states-bucket-${PROJECT_ID}

echo -e "\033[32mCreate terraform service account and its json key...\033[0m"
gcloud iam service-accounts create terraform

gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/owner
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/storage.admin
gcloud projects add-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.imageUser
gcloud projects add-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/dns.admin
gcloud projects add-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.networkAdmin
gcloud projects add-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:$(gcloud projects describe ${PROJECT_ID} --format=json | jq -r '.projectNumber')@cloudservices.gserviceaccount.com --role=roles/compute.imageUser

gcloud iam service-accounts keys create .${PROJECT_NAME}-key.json  --iam-account terraform@${PROJECT_ID}.iam.gserviceaccount.com

echo -e "\033[32mWrite tfvars and backend files.\033[0m"
cat <<EOT > gcp.tfvars
region                = "${REGION}"
zone                  = "${REGION}-a"
project_id            = "${PROJECT_ID}"
prefix                = "${PROJECT_NAME}"
google_account_file   = ".${PROJECT_NAME}-key.json"
external_domain       = "cloud.bitrock.it"
use_le_staging        = true
dc_name               = "gcp-dc"
control_plane_sa_name = "control-plane"
worker_plane_sa_name  = "worker-plane"
image                 = "projects/${PARENT_PROJECT_ID}/global/images/family/hashicorp-centos-image"
parent_dns_project_id = "${PARENT_PROJECT_ID}"
parent_dns_zone_name  = "dns-example-zone"
EOT

cat <<EOT > backend.tf
terraform {
  backend "gcs" {
    bucket = "states-bucket-${PROJECT_ID}"
    prefix = "infraboot/terraform/state"
    credentials = ".${PROJECT_NAME}-key.json"
  }
}
EOT


cat <<EOT > run.sh
#!/usr/bin/env bash
set -e

EXTERNAL_DOMAIN="example.com" # replace
export VAULT_ADDR="https://vault.${PREFIX}.\${EXTERNAL_DOMAIN}"
export CONSUL_ADDR="https://consul.${PREFIX}.\${EXTERNAL_DOMAIN}"
export NOMAD_ADDR="https://nomad.${PREFIX}.\${EXTERNAL_DOMAIN}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Deploying infrastructure..."

terraform init -reconfigure -upgrade
terraform apply -var-file ${CLOUD_NAME}.tfvars -auto-approve

export VAULT_TOKEN=$(cat ".${PREFIX}-root_token")
export NOMAD_TOKEN=$(vault read -tls-skip-verify -format=json nomad/creds/token-manager | jq -r .data.secret_id)

echo "Waiting for Vault \${VAULT_ADDR} to be up..."
while [ $(curl -k --silent --output /dev/null --write-out "%{http_code}" "\${VAULT_ADDR}/v1/sys/leader") != "200" ]; do
  echo "Waiting for Vault to be up..."
  sleep 5
done

echo "Waiting for Consul \${CONSUL_ADDR} to be up..."
while [ $(curl -k --silent --output /dev/null --write-out "%{http_code}" "\${CONSUL_ADDR}/v1/status/leader") != "200" ]; do
  echo "Waiting for Consul to be up..."
  sleep 5
done

echo "Waiting for Nomad \${NOMAD_ADDR} to be up..."
while [ $(curl -k --silent --output /dev/null --write-out "%{http_code}" "\${NOMAD_ADDR}/v1/status/leader") != "200" ]; do
  echo "Waiting for Nomad to be up..."
  sleep 5
done

echo "Configuring platform..."

cd "$DIR/../caravan-platform"
cp "${PREFIX}-${CLOUD_NAME}-backend.tf.bak" "backend.tf"

terraform init -reconfigure -upgrade
terraform apply -var-file "${PREFIX}-${CLOUD_NAME}.tfvars" -auto-approve

echo "Waiting for Consul Connect to be ready..."
while [ $(curl -k --silent --output /dev/null --write-out "%{http_code}" "\${CONSUL_ADDR}/v1/connect/ca/roots") != "200" ]; do
  echo "Waiting for Consul Connect to be ready..."
  sleep 5
done

echo "Configuring application support..."

cd "$DIR/../caravan-application-support"
cp "${PREFIX}-${CLOUD_NAME}-backend.tf.bak" "backend.tf"

terraform init -reconfigure -upgrade
terraform apply -var-file "${PREFIX}-${CLOUD_NAME}.tfvars" -auto-approve

echo "Configuring sample workload..."

cd "$DIR/../caravan-workload"
cp "${PREFIX}-${CLOUD_NAME}-backend.tf.bak" "backend.tf"

terraform init -reconfigure -upgrade
terraform apply -var-file "${PREFIX}-${CLOUD_NAME}.tfvars" -auto-approve

cd "$DIR"

echo "Done."
EOT

cat <<EOT > destroy.sh
#!/usr/bin/env bash
set -e

EXTERNAL_DOMAIN="example.com" # replace
export VAULT_ADDR="https://vault.${PREFIX}.\${EXTERNAL_DOMAIN}"
export CONSUL_ADDR="https://consul.${PREFIX}.\${EXTERNAL_DOMAIN}"
export NOMAD_ADDR="https://nomad.${PREFIX}.\${EXTERNAL_DOMAIN}"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export VAULT_TOKEN=$(cat ".${PREFIX}-root_token")
export NOMAD_TOKEN=$(vault read -tls-skip-verify -format=json nomad/creds/token-manager | jq -r .data.secret_id)

echo "Destroying sample workload..."

cd "$DIR/../caravan-workload"
cp "${PREFIX}-${CLOUD_NAME}-backend.tf.bak" "backend.tf"

terraform init -reconfigure -upgrade
terraform destroy -var-file "${PREFIX}-${CLOUD_NAME}.tfvars" -auto-approve

echo "Destroying application support..."

cd "$DIR/../caravan-application-support"
cp "${PREFIX}-${CLOUD_NAME}-backend.tf.bak" "backend.tf"

terraform init -reconfigure -upgrade
terraform destroy -var-file "${PREFIX}-${CLOUD_NAME}.tfvars" -auto-approve

echo "Destroying platform..."

cd "$DIR/../caravan-platform"
cp "${PREFIX}-${CLOUD_NAME}-backend.tf.bak" "backend.tf"

terraform init -reconfigure -upgrade
terraform destroy -var-file "${PREFIX}-${CLOUD_NAME}.tfvars" -auto-approve

echo "Destroying infrastructure..."

cd "$DIR"

terraform init -reconfigure -upgrade
terraform apply -var-file ${CLOUD_NAME}.tfvars -auto-approve

echo "Done."
EOT

chmod +x run.sh
chmod +x destroy.sh

echo -e "\033[32m
Done!
All set, review configs and execute 'run.sh' and 'destroy.sh'.
Don't forget to add the service account \"terraform@${PROJECT_ID}.iam.gserviceaccount.com\" at https://www.google.com/webmasters/verification for your parent DNS zone.
\033[0m"
