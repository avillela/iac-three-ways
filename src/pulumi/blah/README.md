# Set up Pulumi for Python

1- gCloud authentication

Log into GCP

```bash
gcloud config set project <your_project_name>
gcloud auth application-default login
```

**NOTES:**
* Make sure that the [Kubernetes Engine API is enabled](https://console.cloud.google.com/apis/api/container.googleapis.com) for your project.
* Make sure that `gke-gcloud-auth-plugin` is enabled. To enable it, run `  gcloud components install gke-gcloud-auth-plugin`

2- Set up Python

```bash
# Set up virtualenv
pip install virtualenv
virtualenv venv
source  venv/bin/activate
python -m pip install --upgrade pip

# Install requirements Pulumi + GCP + GKE
pip install -r requirements.txt
```

3- Initialize Pulumi

This example assumes that you're using app.pulumi.com to store your stack. As a pre-requisite, you'll get set up [here](https://app.pulumi.com/). The service is free for personal use.

```bash
pulumi stack init dev
```

Additional commands

```bash
# Select stack
pulumi stack select <stackname>

# Use delete stack
pulumi stack rm <stackname>

# List stacks
pulumi stack ls
```

4- Configure GCP project in Pulumi

```bash
pulumi config set gcp:project <your_project_name>
pulumi config set gcp:region <region>
pulumi config set gcp:zone <zone>
```

Find compute zones and regions

```bash
gcloud compute zones list
```


5- Provision infrastructure

