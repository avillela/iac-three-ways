# Retrieve an access token as the Terraform runner
data "google_client_config" "provider" {} 

# Canary deployment example
resource "kubernetes_namespace_v1" "ns" {

  metadata {
    name = var.canary_deployment_namespace

    labels = {
      app = "canary-${var.project_id}"
    }
  }
}


resource "kubernetes_deployment_v1" "canary" {
  metadata {
    name      = "deploy-nginx"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name

    labels = {
      app = kubernetes_namespace_v1.ns.metadata.0.labels.app
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = kubernetes_namespace_v1.ns.metadata.0.labels.app
      }
    }

    template {
      metadata {
        labels = {
          app = kubernetes_namespace_v1.ns.metadata.0.labels.app
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx"

          resources {
            limits = {
              cpu    = "1"
              memory = "256Mi"
            }
            requests = {
              cpu    = "500m"
              memory = "30Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8080

              http_header {
                name  = "X-Custom-Header"
                value = "GreatBlogArticle"
              }
            }

            initial_delay_seconds = 2
            period_seconds        = 2
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "ingress" {
  metadata {
    name      = "ingress"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
  }
  spec {
    selector = {
      # app = kubernetes_deployment_v1.canary.spec.0.template.0.metadata.0.labels.app
      app = kubernetes_namespace_v1.ns.metadata.0.labels.app
    }
    port {
      port        = 4444
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}