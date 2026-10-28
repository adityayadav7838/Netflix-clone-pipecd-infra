module "namespace" {
  source = "../../modules/namespace"

  namespace_name = "netflix-clone-staging"
  environment    = "staging"
}
