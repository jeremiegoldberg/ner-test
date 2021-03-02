resource "helm_release" "prometheus-community" {
  name       = "prometheus-community"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  set {
    name  = "server.persistentVolume.size"
    value = "100Gi"
  }
  set {
    name  = "server.retention"
    value = "30d"
  }
}

resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata.0.name

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "persistence.type"
    value = "pvc"
  }
  set {
    name  = "persistence.size"
    value = "10Gi"
  }
}