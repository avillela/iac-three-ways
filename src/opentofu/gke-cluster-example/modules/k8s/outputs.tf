output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}

output "ca_certificate" {
  description = "Public certificate of the cluster (base64-encoded)."
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate 
  sensitive   = true
}

output "access_token" {
  value       = data.google_client_config.default.access_token
  description = "The access token to auth cluster"

}
