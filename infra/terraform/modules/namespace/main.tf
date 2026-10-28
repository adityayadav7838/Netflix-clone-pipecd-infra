resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace_name

    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}
