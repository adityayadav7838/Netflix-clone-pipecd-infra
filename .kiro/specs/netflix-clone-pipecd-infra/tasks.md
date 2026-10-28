# Implementation Plan

- [x] 1. Set up repository directory layout
  - Create `infra/terraform/modules/namespace/`, `infra/terraform/envs/{dev,staging,prod}/`, `infra/k8s/base/`, and `infra/k8s/overlays/{local,staging,prod}/` directory structure with placeholder files
  - Create `.kiro/steering/` directory if it does not exist
  - _Requirements: 1.1_

- [x] 2. Implement Terraform namespace module
- [x] 2.1 Create shared `modules/namespace` module files
  - Write `main.tf` with `kubernetes_namespace` resource and environment label
  - Write `variables.tf` with `namespace_name` and `environment` inputs
  - Write `outputs.tf` exporting `namespace_name`
  - Write `versions.tf` pinning `hashicorp/kubernetes ~> 2.31` and declaring `terraform >= 1.5`
  - _Requirements: 4.1, 4.2, 4.3, 4.5_

- [x] 2.2 Create environment root modules for dev, staging, and prod
  - Write `main.tf` in each env root calling `../../modules/namespace` with appropriate `namespace_name` and `environment` values
  - Write `versions.tf` in each env root with local backend (`terraform.tfstate`) and kubernetes provider pinned to `~> 2.31`
  - Write `variables.tf` with `kubeconfig_path` and `kube_context` inputs defaulting to `~/.kube/config`
  - Write `outputs.tf` re-exporting `namespace_name` from the module
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 2.3 Validate Terraform modules
  - Run `terraform init` and `terraform validate` in each env root to confirm syntax and provider resolution
  - _Requirements: 4.1, 4.3_

- [x] 3. Implement Kubernetes base manifests
- [x] 3.1 Create base manifest files
  - Write `infra/k8s/base/namespace.yaml` defining `Namespace` named `netflix-clone`
  - Write `infra/k8s/base/deployment.yaml` with `replicas: 1`, image `netflix-clone:local`, `imagePullPolicy: Never`
  - Write `infra/k8s/base/service.yaml` with `type: NodePort`, container port `80`, `nodePort: 30080`
  - Write `infra/k8s/base/kustomization.yaml` listing all three resources
  - _Requirements: 3.1, 3.2, 3.3, 3.5_

- [x] 3.2 Create Kustomize overlays for local, staging, and prod
  - Write `infra/k8s/overlays/local/kustomization.yaml` setting `namespace: netflix-clone` and image tag `netflix-clone:local`
  - Write `infra/k8s/overlays/staging/kustomization.yaml` and `infra/k8s/overlays/prod/kustomization.yaml` with equivalent namespace patches and placeholder image tags
  - _Requirements: 3.4, 3.5_

- [x] 3.3 Validate Kustomize overlays render correctly
  - Run `kubectl kustomize infra/k8s/overlays/local` to confirm the overlay builds without errors
  - _Requirements: 3.4_

- [x] 4. Create PipeCD application configuration
  - Write `infra/k8s/overlays/local/.pipe.yaml` defining a `KubernetesApp` targeting namespace `netflix-clone` with `repoId: default` and path `infra/k8s/overlays/local`
  - Include pipeline stages: `K8S_CANARY_ROLLOUT` → `WAIT_APPROVAL` (timeout 10m) → `K8S_PRIMARY_ROLLOUT` → `K8S_CANARY_CLEAN`
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 5. Create Gangsta AI steering file
  - Write `.kiro/steering/gangsta-infra.md` with Omerta laws (Spec is Law, Rule of Truth, Rule of Availability)
  - Add Heist pipeline phase-to-infra-task mapping section
  - Add terraform-skill Response Contract template (Assumptions, Risk category, Chosen remediation, Validation plan, Rollback notes)
  - Add Glossary cross-reference section pointing to terms in `requirements.md`
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 6. Wire everything together with a build and load script
  - Write a shell script `infra/scripts/build-and-load.sh` that builds the Docker image with `TMDB_V3_API_KEY` build arg and loads it into kind using `kind load docker-image netflix-clone:local`
  - Script must accept `--api-key` and `--cluster-name` flags with safe defaults (empty key, `kind` cluster name)
  - _Requirements: 2.1, 2.2, 2.3, 2.4_
