#!/bin/bash

# Reference
# https://www.pulumi.com/docs/iac/get-started/gcp/begin/
# https://www.pulumi.com/registry/packages/gcp/installation-configuration/ 

gcloud config set project ${GCP_PROJECT_NAME}
gcloud auth application-default login

# Scaffold a new Pulumi GCP project using the Python SDK and create a new stack
pulumi new gcp-python \
    -n gke-cluster-example \
    -s dev \
    -d "Provision a GKE cluster" -y

# Configure Pulumi stack
pulumi config set gcp:project ${GCP_PROJECT_NAME}
pulumi config set gcp:region ${GCP_REGION}
pulumi config set gcp:zone ${GCP_ZONE}