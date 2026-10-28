variable "namespace_name" {
  description = "The name of the Kubernetes namespace to create."
  type        = string
}

variable "environment" {
  description = "Environment label applied to the namespace (e.g. dev, staging, prod)."
  type        = string
}
