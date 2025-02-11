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

# # OTel Demo App deploy
# resource "kubernetes_namespace_v1" "otel_demo_ns" {
#   metadata {
#     name = var.otel_demo_namespace
#   }
# }

# resource "kubernetes_secret_v1" "ls_access_token_demo" {
#   depends_on = [kubernetes_namespace_v1.otel_demo_ns]
#   metadata {
#     name      = "otel-collector-secret"
#     namespace = var.otel_demo_namespace
#   }

#   data = {
#     "LS_TOKEN" = var.ls_access_token
#   }
# }

# resource "helm_release" "otel_demo_app" {
#   depends_on = [helm_release.otel-kube-stack, kubernetes_namespace_v1.otel_demo_ns]
#   name             = "otel-demo-app"
#   repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
#   chart            = "opentelemetry-demo"
#   version          = "0.9.6"  
#   timeout          = 120
#   namespace        = var.otel_demo_namespace
#   wait             = false

#   values = [
#      "${file("configs/otel-demo-app-values.yaml")}" 
#   ]
# }

# # Create NS for cert manager and kubestack
# resource "kubernetes_namespace_v1" "otel_kube_stack_ns" {
#   metadata {
#     name = var.otel_kube_stack_namespace
#   }
# }

# resource "kubernetes_namespace_v1" "opentelemetry_operator_ns" {
#   metadata {
#     name = var.opentelemetry_operator_namespace
#   }
# }

# # Deploy cert manager
# resource "helm_release" "cert-manager" {
#     name = "cert-manager"
#     namespace = var.cert_manager_namespace
#     repository = "https://charts.jetstack.io"
#     chart = "cert-manager"
#     create_namespace = true
#     version = "1.8.0"
#     set {
#         name = "installCRDs"
#         value = "true"
#     }
#     wait_for_jobs = true
# }

# resource "helm_release" "otel-operator" {
#     depends_on = [helm_release.cert-manager]
#     name = "otel-operator"
#     namespace = var.opentelemetry_operator_namespace
#     repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
#     chart = "opentelemetry-operator"
#     wait_for_jobs = true
#     create_namespace = true
# }

# # Deploy otel kube stack
# resource "helm_release" "otel-kube-stack" {
#     depends_on = [helm_release.otel-operator, kubernetes_namespace_v1.otel_kube_stack_ns] 
#     name = "otel-kube-stack"
#     chart = "./prometheus-k8s-opentelemetry-collector/kube-otel-stack"
#     dependency_update = true
#     values = [
#         "${file("configs/prometheus-values.yaml")}"
#     ]
#     namespace = var.otel_kube_stack_namespace
#     wait_for_jobs = true
# }

# resource "kubernetes_secret_v1" "ls_access_token" {
#   depends_on = [kubernetes_namespace_v1.otel_kube_stack_ns]
#   metadata {
#     name      = "otel-collector-secret"
#     namespace = var.otel_kube_stack_namespace
#   }

#   data = {
#     "LS_TOKEN" = var.ls_access_token
#   }
# }

