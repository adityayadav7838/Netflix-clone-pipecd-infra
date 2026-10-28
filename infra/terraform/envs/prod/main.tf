module "namespace" {
  source = "../../modules/namespace"

  namespace_name = "netflix-clone-prod"
  environment    = "prod"
}
