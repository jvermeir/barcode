# Kubernetes cluster module for OVH Cloud

# Create Managed Kubernetes cluster
resource "ovh_cloud_project_kube" "cluster" {
  service_name = var.project_id
  name         = "${var.environment}-${var.cluster_name}"
  region       = var.region
  version      = var.kubernetes_version
  
  private_network_id = var.network_id
  
  # Private network configuration
  private_network_configuration {
    default_vrack_gateway              = ""
    private_network_routing_as_default = true
  }
}

# Create node pool for the cluster
resource "ovh_cloud_project_kube_nodepool" "pool" {
  service_name  = var.project_id
  kube_id       = ovh_cloud_project_kube.cluster.id
  name          = "default-pool"
  flavor_name   = var.node_flavor
  desired_nodes = var.desired_nodes
  min_nodes     = var.min_nodes
  max_nodes     = var.max_nodes
  autoscale     = true
  anti_affinity = false
  monthly_billed = false
}

# Get kubeconfig
resource "ovh_cloud_project_kube_kubeconfig" "kubeconfig" {
  service_name = var.project_id
  kube_id      = ovh_cloud_project_kube.cluster.id
}

# Create namespace for backend
resource "kubernetes_namespace" "backend" {
  metadata {
    name = "barcode-backend"
    labels = {
      name        = "barcode-backend"
      environment = var.environment
    }
  }
  
  depends_on = [ovh_cloud_project_kube_nodepool.pool]
}

# Create secret for database credentials
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "db-credentials"
    namespace = kubernetes_namespace.backend.metadata[0].name
  }

  data = {
    DATABASE_URL      = "jdbc:postgresql://${var.db_host}:${var.db_port}/${var.db_name}"
    DATABASE_USERNAME = var.db_username
    DATABASE_PASSWORD = var.db_password
    DB_HOST           = var.db_host
    DB_PORT           = tostring(var.db_port)
    DB_NAME           = var.db_name
  }

  type = "Opaque"
}

# Deploy backend application
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "barcode-backend"
    namespace = kubernetes_namespace.backend.metadata[0].name
    labels = {
      app         = "barcode-backend"
      environment = var.environment
    }
  }

  spec {
    replicas = var.backend_replicas

    selector {
      match_labels = {
        app = "barcode-backend"
      }
    }

    template {
      metadata {
        labels = {
          app         = "barcode-backend"
          environment = var.environment
        }
      }

      spec {
        container {
          name  = "backend"
          image = var.backend_image

          port {
            container_port = 8080
            name          = "http"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.db_credentials.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/barcodes/health"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/barcodes/health"
              port = 8080
            }
            initial_delay_seconds = 20
            period_seconds        = 5
            timeout_seconds       = 3
          }
        }
      }
    }
  }
}

# Create service for backend
resource "kubernetes_service" "backend" {
  metadata {
    name      = "barcode-backend-service"
    namespace = kubernetes_namespace.backend.metadata[0].name
    labels = {
      app = "barcode-backend"
    }
  }

  spec {
    selector = {
      app = "barcode-backend"
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
      name        = "http"
    }

    type = "LoadBalancer"
  }
}

# Create ingress for backend (optional)
resource "kubernetes_ingress_v1" "backend" {
  count = var.enable_ingress ? 1 : 0

  metadata {
    name      = "barcode-backend-ingress"
    namespace = kubernetes_namespace.backend.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = var.backend_domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.backend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
