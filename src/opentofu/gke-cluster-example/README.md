# Use OpenTofu to Create a Kubernetes Cluster in Google Cloud

## Setup

### 1- gCloud authentication

Log into GCP

```bash
gcloud auth login
gcloud config set project <your_project_name>
gcloud auth application-default login
```

### 2- Set up OpenTofu

```bash
cd src/opentofu/gke-cluster-example

# Download modules
tofu init

# Run plan
tofu plan

# Execute plan
tofu apply -auto-approve
```

To destroy your infrastructure, run:

```bash
tofu destroy
```

## References

TBD