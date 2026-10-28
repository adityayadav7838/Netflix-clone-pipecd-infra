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

variable "tmdb_api_key" {
  description = "TMDB V3 API key injected at runtime into the netflix-clone pod via a Kubernetes Secret. Never stored in state as plaintext — marked sensitive."
  type        = string
  sensitive   = true
  default     = ""
}
