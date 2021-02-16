#! /bin/bash

set -e

BILLING_ACCOUNT_ID=$1
ORG_ID=$2
PARENT_PROJECT_ID=$3
PROJECT_ID=$4
PROJECT_NAME=$5
REGION=$6

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

gcloud iam service-accounts keys create .${PROJECT_ID}-key.json  --iam-account terraform@${PROJECT_ID}.iam.gserviceaccount.com

echo -e "\033[32m
Done!
Don't forget to add the service account \"terraform@${PROJECT_ID}.iam.gserviceaccount.com\" at https://www.google.com/webmasters/verification for your parent DNS zone.
\033[0m"
