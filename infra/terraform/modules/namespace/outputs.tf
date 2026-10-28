output "namespace_name" {
  description = "The name of the created Kubernetes namespace."
  value       = kubernetes_namespace.this.metadata[0].name
}
