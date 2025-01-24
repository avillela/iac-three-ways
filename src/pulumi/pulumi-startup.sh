#!/bin/bash

# Reference
# https://www.pulumi.com/docs/iac/get-started/gcp/begin/
# https://www.pulumi.com/registry/packages/gcp/installation-configuration/ 

gcloud config set project ${GCP_PROJECT_NAME}
gcloud auth application-default login

pulumi new gcp-python -f

pulumi stack init dev