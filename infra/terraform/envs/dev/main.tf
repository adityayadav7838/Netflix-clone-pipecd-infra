module "namespace" {
  source = "../../modules/namespace"

  namespace_name = "netflix-clone"
  environment    = "dev"
}

resource "kubernetes_secret" "tmdb_api_key" {
  metadata {
    name      = "tmdb-api-key"
    namespace = module.namespace.namespace_name
  }

  data = {
    TMDB_V3_API_KEY = base64encode(var.tmdb_api_key)
  }

  type = "Opaque"
}

resource "null_resource" "apply_manifests" {
  depends_on = [
    module.namespace,
    kubernetes_secret.tmdb_api_key,
  ]

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "kubectl kustomize ${abspath("${path.root}/../../../k8s/overlays/local")} | kubectl apply -f -"
  }
}
