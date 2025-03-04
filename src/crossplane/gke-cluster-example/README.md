# Use Crossplane to Create a Kubernetes Cluster in Google Cloud


## Step 1: Authenticate Google Cloud Shell (gcloud)
```bash
gcloud auth login
```

## Step 2: Install kind and Create Kind Cluster

```bash
brew install kind
```

```bash
kind create cluster --name crossplane-cluster
kubectl cluster-info --context kind-crossplane-cluster
```

## Step 3: Install and Setup Crossplane

```bash
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane \
--namespace crossplane-system \
--create-namespace crossplane-stable/crossplane
```

## Step 4: Create a Kubernetes Cluster in Google Cloud
### Install Google Cloud Provider Family
```bash
kubectl apply -f gcp-provider.yaml
```
### Install Google Cloud Container Provider 
```bash
kubectl apply -f gcp-container-provider.yaml
```
### Verify 
```bash
kubectl get providers
```
### Create Service Account on Google Cloud

### Download JSON for Service Account
```bash
gcloud iam service-accounts keys create key.json \
--iam-account=crossplane-sa@<project-id>.iam.gserviceaccount.com
```
### Rename JSON file to gcp-credentials.json
```bash
mv key.json gcp-credentials.json
```
### Create a Kubernetes Secret with GCP credentials
```bash
kubectl create secret generic gcp-secret \
--namespace crossplane-system \
--from-file=creds=./gcp-credentials.json
```
### Create a ProviderConfig 
A ProviderConfig customizes the settings of the GCP Provider.
* Replace `project-id` with your project id 
```bash
kubectl apply -f gcp-provider-config.yaml
```
### Create Cluster Claim
```bash
kubectl apply -f gcp-cluster-claim.yaml
```
### Create NodePool Claim
```bash
kubectl apply -f gcp-node-pool-claim.yaml
```
### Verify
* Ensure you are on the kind cluster
```bash
kubectl config use-context kind-crossplane-cluster
kubectl get Clusters
kubectl get nodepools
```

## Step 5: Switch to the new cluster
```bash
gcloud container clusters get-credentials <cluster-name> --zone <zone>> --project <project-id>
```
## Step 6: Verify
```bash
kubectl get nodes
```

## Step 7: Deploy a test application - nginx
```bash
kubectl apply -f nginx-deployment.yaml
```

## Step 8: Verify
```bash
kubectl get pods
```