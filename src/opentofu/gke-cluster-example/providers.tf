terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.18.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.18.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }
  }

  required_version = ">= v1.9.0"
}


provider "google" {
  project = var.project_id
  region  = var.region
}


data "google_client_config" "default" {
  depends_on = [module.k8s_cluster_create]
}

data "google_container_cluster" "primary" {
  depends_on = [module.k8s_cluster_create]
  name     = var.cluster_name
  location = var.zone
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = data.google_container_cluster.primary.endpoint
    client_certificate  = data.google_container_cluster.primary.master_auth.0.client_certificate
    token    = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}