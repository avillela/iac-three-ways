variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "zone" {
  description = "zone"
}

variable "network" {
  description = "network name"
}

variable "subnet" {
  description = "subnet name"
}

variable "cluster_name" {
  description = "cluster name"
}

variable "disk_size_gb" {
  description = "disk size in GB"
}

variable "disk_type" {
  description = "disk type"
}

variable "image_type" {
  description = "node image type"
}

variable "node_count" {
  description = "number of gke nodes"
}

variable "node_machine_type" {
  description = "node machine type"
}

variable "canary_deployment_namespace" {
  default = "canary-example"
  description = "Namespace of Canary deployment"
}