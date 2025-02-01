# Use OpenTofu to Create a Kubernetes Cluster in Google Cloud

1- gCloud authentication

Log into GCP

```bash
gcloud config set project <your_project_name>
gcloud auth application-default login
```

Make sure that the [Kubernetes Engine API is enabled](https://console.cloud.google.com/apis/api/container.googleapis.com) for your project.

Make sure that `gke-gcloud-auth-plugin` is enabled. To enable it, run:

```bash
sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin
gcloud auth login
```

2- Set up OpenTofu

```bash
cd src/opentofu/gke-cluster-example

# Download modules
tofu init

# Run plan
tofu plan

# Execute plan
tofu apply -auto-approve
```

# References

* https://search.opentofu.org/module/jwduarteg/gke/google/latest/example/gke-basic-helm
* 