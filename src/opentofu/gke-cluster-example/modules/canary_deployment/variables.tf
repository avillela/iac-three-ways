variable "canary_deployment_namespace" {
  default = "canary-example"
  description = "Namespace of Canary deployment"
}

variable "cluster_name" {
  description = "cluster name"
}

variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "network" {
  description = "network name"
}

variable "subnet" {
  description = "subnet name"
}