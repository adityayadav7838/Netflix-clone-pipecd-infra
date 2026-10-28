# Requirements Document

## Introduction

This feature delivers a complete local Kubernetes infrastructure to build, containerize, and deploy the Netflix Clone React application (TypeScript + Vite + MUI) onto a local `kind` cluster using PipeCD as the GitOps continuous delivery platform. The platform integrates the **Gangsta AI agentic skills framework** for spec-driven, structured AI agent utilization, and the **terraform-skill** for AI-guided Terraform authoring. Infrastructure-as-Code is managed via Terraform (local backend, `kind` provider or `helm` provider), Kubernetes manifests are organized in a GitOps layout, and PipeCD deploys the application by watching this repository. All components run fully offline on the developer's local machine.

## Glossary

- **Application**: The Netflix Clone React SPA built from `Application-Code/` using Vite, served by NGINX inside a Docker container.
- **kind**: Kubernetes-in-Docker — a local Kubernetes cluster tool used as the target runtime.
- **PipeCD**: An open-source GitOps continuous delivery platform already running in the `pipecd` namespace on the kind cluster.
- **Piped**: The PipeCD agent running inside the cluster that watches Git repositories and executes deployments.
- **PipeCD Application**: A PipeCD CR (Custom Resource equivalent, defined in `.pipe.yaml`) that maps a Git path to a Kubernetes deployment.
- **Gangsta**: An AI agentic skills framework (`kucherenko/gangsta`) providing structured spec-driven development phases (Reconnaissance → Grilling → Sit-Down → Resource Development → Execution → Delivery) and governance rules (Omerta Laws).
- **Gangsta SKILL**: A behavior-shaping instruction file loaded by an AI agent to guide a specific phase of work (e.g., `gangsta:reconnaissance`, `gangsta:the-hit`).
- **terraform-skill**: An AI skill from `antonbabenko/terraform-skill` that provides diagnose-first Terraform authoring guidance, module patterns, and CI/CD workflow templates.
- **GitOps Repository**: This project repository, which serves as the single source of truth for both application code and infrastructure manifests.
- **Infra directory**: The `infra/` directory at the repo root containing all Terraform modules and Kubernetes manifests.
- **Namespace**: A Kubernetes namespace isolating the application workload, distinct from the `pipecd` namespace.
- **ConfigMap (piped)**: The Kubernetes ConfigMap in the `pipecd` namespace that configures the Piped agent, including which Git repositories to watch.
- **TMDB API Key**: A build-time secret required by the application as `VITE_APP_TMDB_V3_API_KEY`, passed as a Docker build argument.
- **NodePort**: A Kubernetes service type that exposes the application on a static port accessible from the host machine.
- **Kustomize**: A Kubernetes manifest templating tool used to layer environment-specific configuration over base manifests.
- **`.pipe.yaml`**: The PipeCD application configuration file placed in the GitOps path that tells PipeCD how to deploy the application.
- **Gangsta Harness**: The set of Gangsta SKILL files installed in `.kiro/` (or `.agents/skills/`) that shape AI agent behavior during spec execution.

---

## Requirements

### Requirement 1: GitOps Repository Layout

**User Story:** As a platform engineer, I want a clearly structured GitOps repository layout so that PipeCD can discover and deploy the application from a well-known path.

#### Acceptance Criteria

1. THE GitOps Repository SHALL contain an `infra/` directory with subdirectories `terraform/`, `k8s/base/`, and `k8s/overlays/local/`.
2. THE GitOps Repository SHALL contain a `.pipe.yaml` file at the root of the Kubernetes overlay path (`infra/k8s/overlays/local/`) that defines the PipeCD application configuration for the Netflix Clone deployment.
3. WHEN a developer pushes a change to the `infra/k8s/` path in the repository, THE Piped agent SHALL detect the change within the configured `syncInterval` (1 minute) and trigger a sync.
4. THE GitOps Repository SHALL contain Gangsta SKILL files under `.kiro/` so that AI agents assisting with this repository use spec-driven, Omerta-governed behavior.

---

### Requirement 2: Container Image Build

**User Story:** As a platform engineer, I want the Netflix Clone application containerized with a reproducible Docker build so that PipeCD can deploy a known image to the cluster.

#### Acceptance Criteria

1. THE Application SHALL be built using the existing multi-stage `Application-Code/Dockerfile` (Node 20 builder → NGINX stable-alpine server).
2. WHEN building the container image, THE build system SHALL accept `TMDB_V3_API_KEY` as a build argument and pass it as `VITE_APP_TMDB_V3_API_KEY` to the Vite build.
3. THE built container image SHALL be tagged with a deterministic tag (e.g., `netflix-clone:local`) and loaded into the kind cluster's container runtime using `kind load docker-image`.
4. IF the `TMDB_V3_API_KEY` build argument is not provided, THEN THE build system SHALL use an empty string default so the image still builds, with degraded API functionality.

---

### Requirement 3: Kubernetes Manifests

**User Story:** As a platform engineer, I want Kubernetes manifests for the application so that PipeCD can apply them declaratively to the cluster.

#### Acceptance Criteria

1. THE Kubernetes manifests SHALL define a `Deployment` resource for the Application with `replicas: 1`, using the `netflix-clone:local` image with `imagePullPolicy: Never`.
2. THE Kubernetes manifests SHALL define a `Service` resource of type `NodePort` that exposes the Application on port 80 of the container, mapped to a fixed NodePort (e.g., `30080`) on the cluster node.
3. THE Kubernetes manifests SHALL define a dedicated Kubernetes `Namespace` named `netflix-clone` to isolate the Application workload.
4. WHEN Kustomize processes the overlay at `infra/k8s/overlays/local/`, THE resulting manifests SHALL target the `netflix-clone` namespace and reference the `netflix-clone:local` image tag.
5. THE base manifests at `infra/k8s/base/` SHALL be environment-agnostic and reusable for additional overlays (e.g., staging) without modification.

---

### Requirement 4: Terraform Infrastructure Module

**User Story:** As a platform engineer, I want a Terraform module that provisions the `netflix-clone` namespace on the kind cluster so that the infrastructure is codified and reproducible.

#### Acceptance Criteria

1. THE Terraform module at `infra/terraform/` SHALL use a local state backend (`.tfstate` file) and the `hashicorp/kubernetes` provider to create the `netflix-clone` namespace.
make this infra with include heirarchey create all 3 envs wise -dev-staging-prod
2. THE Terraform module SHALL follow terraform-skill module layout conventions: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.
3. THE Terraform module `versions.tf` SHALL pin the `hashicorp/kubernetes` provider to a specific version constraint (e.g., `~> 2.31`).
4. WHEN `terraform apply` is run, THE Kubernetes provider SHALL authenticate using the local kubeconfig file (`~/.kube/config`) without requiring cloud credentials.
5. THE Terraform module `outputs.tf` SHALL export the namespace name so downstream modules or scripts can reference it without hardcoding.

---

### Requirement 5: PipeCD Application Configuration

**User Story:** As a platform engineer, I want a PipeCD application defined via `.pipe.yaml` so that PipeCD automatically deploys the application when manifests change in Git.

#### Acceptance Criteria

1. THE `.pipe.yaml` file SHALL define a PipeCD application of kind `KubernetesApp` targeting the `netflix-clone` namespace on the local cluster.
2. THE `.pipe.yaml` file SHALL reference the `default` repoId (matching the Piped ConfigMap's repository entry) and the path `infra/k8s/overlays/local`.
3. WHEN PipeCD detects a manifest change in the watched path, THE PipeCD Application SHALL execute a `SYNC` pipeline that applies the Kustomize overlay to the cluster.
4. THE PipeCD Application pipeline config SHALL include a `WAIT_APPROVAL` stage or a `K8S_CANARY_ROLLOUT` stage to demonstrate PipeCD's progressive delivery capability on the local environment.
5. IF a sync fails, THEN THE PipeCD Application SHALL set the deployment status to `FAILURE` and retain the previous running state without rolling back automatically.

---

### Requirement 6: Gangsta AI Harness Integration

**User Story:** As a platform engineer, I want Gangsta AI skill files installed in this repository so that AI agents assisting with infra work follow structured, governed spec-driven behavior.

#### Acceptance Criteria

1. THE GitOps Repository SHALL contain a `.kiro/steering/gangsta-infra.md` steering file that instructs AI agents to follow Gangsta Omerta laws (Spec is Law, Rule of Truth, Rule of Availability) when working on infrastructure tasks.
2. THE steering file SHALL reference the Gangsta Heist pipeline phases (Reconnaissance, Grilling, Sit-Down, Resource Development, Execution, Delivery) and map them to infra tasks in this project.
3. THE steering file SHALL reference the terraform-skill guidance (diagnose-first workflow, Response Contract, module hierarchy) for all Terraform authoring tasks.
4. WHEN an AI agent is asked to modify Terraform code in this repository, THE agent SHALL emit a terraform-skill Response Contract (Assumptions, Risk category, Chosen remediation, Validation plan, Rollback notes) before generating HCL.
5. THE `.kiro/steering/gangsta-infra.md` file SHALL include a Glossary cross-reference pointing agents to the terms defined in this requirements document.
