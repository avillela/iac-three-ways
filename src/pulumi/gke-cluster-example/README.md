# Use Pulumi Python SDK to Create a Kubernetes Cluster in Google Cloud

## Setup

### 1- Google Cloud authentication

Log into Google Cloud and set the project name

```bash
gcloud auth login
gcloud config set project <your_project_name>
gcloud auth application-default login
```

### 2- Navigate to the Pulumi directory

```bash
cd src/pulumi/gke-cluster
```

### 3- Initialize Pulumi

This example assumes that your stack is located in [app.pulumi.com](https://app.pulumi.com). As a pre-requisite, you'll get set up an account [here](https://app.pulumi.com/). The service is free for personal use.

Create a new Pulumi project under your account. This is done one-time only. This will overwrite everything in this directiory, which is fine, because we haven't made any changes to the code.

If getting an account with pulumi.com isn't your jam, you can alternatively manage Pulumi state yourself, either through local storage or cloud provider storage. More info [here](https://www.pulumi.com/docs/pulumi-cloud/faq/#:~:text=If%20you%20use%20your%20own,in%20to%20an%20alternative%20backend.).


```bash
pulumi new https://github.com/avillela/iac-three-ways \
    -n iac-three-ways \
    -s dev \
    -d "Provision a GKE cluster" -y --force
```

Initialize and select the `dev` stack.

```bash
pulumi stack select dev
```

Fully-qualified stackname: https://app.pulumi.com/<your_pulumi_username>/iac-three-ways/dev

4- Provision infrastructure

```bash
# Preview changes
pulumi preview

# Run plan
pulumi up -y
```

To destroy your infrastructure, run:

```bash
pulumi destroy -y
```

## Additional references

Useful Pulumi commands

```bash
# Use delete stack
pulumi stack rm <stackname> -f

# List stacks
pulumi stack ls
```

Useful Google Cloud commands

```bash
# List compute zones and regions
gcloud compute zones list

# List existing projects under given account
gcloud projects list

# List gcloud configurations
gcloud config configurations list
```
