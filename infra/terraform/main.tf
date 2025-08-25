terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.34.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.2"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-edgewatch"
}

provider "helm" {
  kubernetes {
    host                   = null
    config_path            = "~/.kube/config"
    config_context         = "kind-edgewatch"
    insecure               = false
    load_config_file       = true
  }
}

resource "kubernetes_namespace" "edgewatch" {
  metadata {
    name = "edgewatch"
  }
}

# ---- Ingress NGINX (pinned + waits + NodePort for kind) ----
resource "helm_release" "ingress_nginx" {
  name              = "ingress-nginx"
  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"
  version           = "4.11.2"
  namespace         = kubernetes_namespace.edgewatch.metadata[0].name
  create_namespace  = false
  wait              = true
  timeout           = 600
  dependency_update = true

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
}

# ---- PostgreSQL (pinned + waits) ----
resource "helm_release" "postgres" {
  name              = "postgres"
  repository        = "https://charts.bitnami.com/bitnami"
  chart             = "postgresql"
  version           = "15.5.22"
  namespace         = kubernetes_namespace.edgewatch.metadata[0].name
  wait              = true
  timeout           = 600
  dependency_update = true

  set {
    name  = "auth.postgresPassword"
    value = "changeme"
  }
}

resource "kubernetes_deployment" "api" {
  metadata {
    name      = "edgewatch-api"
    namespace = kubernetes_namespace.edgewatch.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "edgewatch-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "edgewatch-api"
        }
      }

      spec {
        container {
          name               = "api"
          image              = "${var.registry}/edgewatch-api:${var.image_tag}"
          image_pull_policy  = "IfNotPresent"

          port {
            container_port = 8000
          }

          security_context {
            run_as_non_root = true
          }

          env {
            name  = "DATABASE_URL"
            value = "postgresql://postgres:changeme@postgres-postgresql:5432/postgres"
          }

          readiness_probe {
            http_get {
              path = "/admin/login/?next=/admin/"
              port = 8000
            }
          }

          liveness_probe {
            http_get {
              path = "/admin/login/?next=/admin/"
              port = 8000
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name      = "edgewatch-api"
    namespace = kubernetes_namespace.edgewatch.metadata[0].name
  }

  spec {
    selector = {
      app = "edgewatch-api"
    }

    port {
      port        = 80
      target_port = 8000
    }
  }
}

# Ensure ingress is created only after the controller is installed
resource "kubernetes_ingress_v1" "api" {
  metadata {
    name      = "edgewatch-api"
    namespace = kubernetes_namespace.edgewatch.metadata[0].name
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "edgewatch.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.api.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.ingress_nginx]
}

