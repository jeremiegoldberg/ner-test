resource "kubernetes_deployment" "wordclass-api" {
  metadata {
    name = "wordclass-api"
    namespace = kubernetes_namespace.videosites-common.metadata.0.name
    labels = {

    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "wordclass-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordclass-api"
        }
      }

      spec {

        image_pull_secrets {
          name = kubernetes_secret.docker_pull_secret_vsc.metadata.0.name
        }

        host_aliases {
          hostnames = ["consul"]
          ip = "10.64.86.27"
        }

        container {
          image = "rg.fr-par.scw.cloud/netasgard/wordclass"
          name  = "wordclass-api"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "2"
              memory = "2048Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordclass-api" {
  metadata {
    name = "wordclass-api-svc"
    namespace = kubernetes_namespace.videosites-common.metadata.0.name
    labels = {
      "app" = "wordclass-api"
    }
    annotations = {
      "prometheus.io/scrape" = "true",
      "prometheus.io/path"  : "/metrics",
      "prometheus.io/port" : "80",
      "prometheus.io/scheme" : "http"
    }
  }

  spec {
    selector = {
      app = "wordclass-api"
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      name        = "http"
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress" "wordclass-api-ingress" {
  metadata {
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
    }
    name = "wordclass-api-ingress"
    namespace = kubernetes_namespace.videosites-common.metadata.0.name
  }

  spec {
    rule {
      host = "wordclass.api"
      http {
        path {
          backend {
            service_name = kubernetes_service.wordclass-api.metadata.0.name
            service_port = 80
          }
        }
      }
    }
  }
}