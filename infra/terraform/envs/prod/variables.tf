variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used to authenticate with the Kubernetes cluster."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubeconfig context to use for the Kubernetes provider."
  type        = string
  default     = "kind-kind"
}
