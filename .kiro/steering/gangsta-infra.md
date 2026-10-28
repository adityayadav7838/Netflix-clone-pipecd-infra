# Gangsta AI Harness — Netflix Clone PipeCD Infrastructure

> This steering file governs all AI agent behavior for infrastructure tasks in this repository.
> It is always included in every AI interaction within this workspace.

---

## Omerta Laws

These laws are non-negotiable. Every AI agent operating in this repository MUST comply.

### Law 1 — Spec is Law

The requirements at `.kiro/specs/netflix-clone-pipecd-infra/requirements.md` and the design at `.kiro/specs/netflix-clone-pipecd-infra/design.md` are the ground truth. No implementation may contradict them. If a conflict arises between an instruction in chat and the spec, the spec wins. Flag the conflict to the user before proceeding.

### Law 2 — Rule of Truth

Do not invent facts, assume provider behavior, or hallucinate Terraform resource arguments. If something is unknown, say so. Run `terraform validate` and `kubectl kustomize` to confirm correctness — never rely on memory alone.

### Law 3 — Rule of Availability

Every artifact produced MUST be immediately usable by a developer with a working `kind` cluster and `kubectl` context. No step may require external cloud credentials, private registries, or non-public tools beyond those listed in the Glossary.

---

## Heist Pipeline — Phase-to-Infra-Task Mapping

The Gangsta Heist pipeline structures all infra work into six phases. Use this mapping when planning or executing any task in this repository.

| Phase | Gangsta Name | Infra Task Mapping |
|---|---|---|
| 1 | **Reconnaissance** | Read current cluster state: `kubectl get ns`, `kubectl get pods -A`, check existing `.pipe.yaml` and Piped ConfigMap |
| 2 | **Grilling** | Validate requirements are met: cross-check tasks.md against requirements.md, confirm all acceptance criteria are addressed |
| 3 | **Sit-Down** | Review and agree on design: confirm design.md decisions (module hierarchy, overlay strategy, pipeline stages) before writing HCL or YAML |
| 4 | **Resource Development** | Write Terraform modules, Kubernetes manifests, Kustomize overlays, and `.pipe.yaml` — following the directory layout in design.md |
| 5 | **Execution** | Apply infrastructure: `terraform apply`, `kubectl kustomize`, commit manifest changes to trigger PipeCD sync, approve `WAIT_APPROVAL` stage |
| 6 | **Delivery** | Verify the running state: `kubectl get pods -n netflix-clone`, confirm NodePort `30080` is accessible, confirm PipeCD deployment status is `SUCCESS` |

---

## terraform-skill Response Contract

Before generating any HCL code, the AI agent MUST emit a Response Contract using the template below. No Terraform code may be written without it.

```
### terraform-skill Response Contract

**Assumptions**
- [List all assumed values, provider versions, cluster context names, kubeconfig paths, and any behavior inferred from the spec rather than observed directly]

**Risk Category**
- [ ] Low   — non-destructive, no state impact (e.g., adding an output)
- [ ] Medium — modifies existing state or provider config
- [ ] High  — destroys or replaces resources, changes backend, or affects shared state

**Chosen Remediation**
- [Describe what HCL will be written or changed, and why this approach satisfies the requirement]

**Validation Plan**
1. `terraform init` — confirm provider download and backend init
2. `terraform validate` — confirm syntax and provider schema compliance
3. `terraform plan` — review resource diff before applying
4. `terraform apply` — apply and confirm namespace appears with `kubectl get ns`

**Rollback Notes**
- [Describe how to undo this change: e.g., `terraform destroy`, manual `kubectl delete ns`, or state manipulation steps]
```

This contract applies to all tasks touching files under `infra/terraform/`.

---

## Glossary Cross-Reference

The following terms are defined in full in `.kiro/specs/netflix-clone-pipecd-infra/requirements.md` under the **Glossary** section. Agents MUST use these definitions consistently and MUST NOT redefine them.

| Term | Defined In |
|---|---|
| Application | requirements.md § Glossary |
| kind | requirements.md § Glossary |
| PipeCD | requirements.md § Glossary |
| Piped | requirements.md § Glossary |
| PipeCD Application | requirements.md § Glossary |
| Gangsta | requirements.md § Glossary |
| Gangsta SKILL | requirements.md § Glossary |
| terraform-skill | requirements.md § Glossary |
| GitOps Repository | requirements.md § Glossary |
| Infra directory | requirements.md § Glossary |
| Namespace | requirements.md § Glossary |
| ConfigMap (piped) | requirements.md § Glossary |
| TMDB API Key | requirements.md § Glossary |
| NodePort | requirements.md § Glossary |
| Kustomize | requirements.md § Glossary |
| `.pipe.yaml` | requirements.md § Glossary |
| Gangsta Harness | requirements.md § Glossary |
