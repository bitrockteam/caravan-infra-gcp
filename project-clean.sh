#! /bin/bash

set -ex

PROJECT_ID=$1
PARENT_PROJECT_ID=$2

echo "Clean some policy binding in "${PARENT_PROJECT_ID}" project..."
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:$(gcloud projects describe ${PROJECT_ID} --format=json | jq -r '.projectNumber')@cloudservices.gserviceaccount.com --role=roles/compute.imageUser
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.imageUser
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/dns.admin
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.networkAdmin
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/iam.serviceAccountUser

echo "Disabling billing in ${PROJECT_ID}..."
gcloud beta billing projects unlink ${PROJECT_ID}

echo "Deleting project ${PROJECT_ID}..."
gcloud projects delete ${PROJECT_ID}

echo "Done!"
