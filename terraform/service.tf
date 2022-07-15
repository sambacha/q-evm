resource "kubernetes_service" "service" {
  metadata {
    name      = var.name
    namespace = var.k8s_namespace
    labels = merge(var.k8s_labels, {
      name = var.name
    })
  }

  spec {
    selector = {
      name = var.name
    }

    port {
      port        = 80
      target_port = "http"
    }

    type = "ClusterIP"
  }
}
