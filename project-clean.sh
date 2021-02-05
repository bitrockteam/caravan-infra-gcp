#! /bin/bash

set -e

PROJECT_ID=$1
PARENT_PROJECT_ID=$2

echo -e "\033[32mClean some policy binding in "${PARENT_PROJECT_ID}" project...\033[0m"
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:$(gcloud projects describe ${PROJECT_ID} --format=json | jq -r '.projectNumber')@cloudservices.gserviceaccount.com --role=roles/compute.imageUser
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.imageUser
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/dns.admin
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.networkAdmin
gcloud projects remove-iam-policy-binding ${PARENT_PROJECT_ID} --member=serviceAccount:terraform@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/iam.serviceAccountUser

echo -e "\033[32mDisabling billing in ${PROJECT_ID}...\033[0m"
gcloud beta billing projects unlink ${PROJECT_ID}

echo -e "\033[32mDeleting project ${PROJECT_ID}...\033[0m"
gcloud projects delete ${PROJECT_ID}

echo -e "\033[32mCleaning folder..\033[0m"
ls -a | grep -i "root-token" | xargs rm
ls -a | grep -i "key.json" | xargs rm

echo -e "\033[32mDone!\033[0m"
