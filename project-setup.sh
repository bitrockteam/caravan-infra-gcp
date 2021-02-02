#! /bin/bash

set -ex

BILLING_ACCOUNT_ID=$1
ORG_ID=$2
PARENT_PROJECT=$3
PROJECT_ID=$4
PROJECT_NAME=$5
REGION=$6

echo "Creating ${PROJECT_ID}, named ${PROJECT_NAME} in ${REGION}..."
gcloud projects create ${PROJECT_ID} --name=${PROJECT_NAME} --organization=${ORG_ID}
gcloud beta billing projects link ${PROJECT_ID} --billing-account ${BILLING_ACCOUNT_ID}
gcloud config set project ${PROJECT_ID}

echo "Enable some GCP services..."
gcloud services enable compute.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    serviceusage.googleapis.com \
    cloudkms.googleapis.com \
    iam.googleapis.com \
    cloudresourcemanager.googleapis.com \
    dns.googleapis.com

echo "Create terraform state bucket..."
gsutil mb -b off -c standard -l ${REGION} -p ${PROJECT_ID} gs://states-bucket-${PROJECT_ID}

echo "Create terraform service account and its json key..."
gcloud iam service-accounts create terraform

gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/owner
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/storage.admin
gcloud projects add-iam-policy-binding ${PARENT_PROJECT} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.imageUser
gcloud projects add-iam-policy-binding ${PARENT_PROJECT} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/dns.admin
gcloud projects add-iam-policy-binding ${PARENT_PROJECT} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.networkAdmin
gcloud projects add-iam-policy-binding ${PARENT_PROJECT} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding ${PARENT_PROJECT} --member=serviceAccount:$(gcloud projects describe ${PROJECT_ID} --format=json | jq -r '.projectNumber')@cloudservices.gserviceaccount.com --role=roles/compute.imageUser

gcloud iam service-accounts keys create .hashicorp-key.json  --iam-account terraform@${PROJECT_ID}.iam.gserviceaccount.com

echo "Write tfvars and backend files."
cat <<EOT > gcp.tfvars
region              = "${REGION}"
zone                = "${REGION}-a"
project_id          = "${PROJECT_ID}"
prefix              = "hashicorp"
google_account_file = ".hashicorp-key.json"
gcp_csi             = true
external_domain     = "cloud.bitrock.it"
use_le_staging = true
dc_name               = "gcp-dc"
control_plane_sa_name = "control-plane"
worker_plane_sa_name  = "worker-plane"
project_image_path  = "projects/hcpoc-terraform-admin/global/images/"
EOT

cat <<EOT > backend.tf
terraform {
  backend "gcs" {
    bucket = "states-bucket-${PROJECT_ID}"
    prefix = "infraboot/terraform/state"
  }
}
EOT

echo "Done!
Don't forget to add the service account \"terraform@${PROJECT_ID}.iam.gserviceaccount.com\" at https://www.google.com/webmasters/verification for your parent DNS zone.
"