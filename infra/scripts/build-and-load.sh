#!/usr/bin/env bash
# build-and-load.sh
# Builds the Netflix Clone Docker image and loads it into a kind cluster.
#
# The TMDB API key is NO LONGER a build argument — it is injected at runtime
# via a Kubernetes Secret. See infra/k8s/base/secret.yaml for instructions.
#
# Usage:
#   ./infra/scripts/build-and-load.sh [--cluster-name <kind_cluster>]
#
# Flags:
#   --cluster-name  Name of the kind cluster to load the image into (default: kind)
#
# Requirements: 2.1, 2.2, 2.3, 2.4

set -euo pipefail

# ── Defaults ────────────────────────────────────────────────────────────────
CLUSTER_NAME="kind"
IMAGE_TAG="netflix-clone:local"
DOCKERFILE_CONTEXT="Application-Code"

# ── Argument parsing ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cluster-name)
      CLUSTER_NAME="${2:-}"
      shift 2
      ;;
    --help|-h)
      sed -n '2,16p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown flag: $1" >&2
      echo "Run with --help for usage." >&2
      exit 1
      ;;
  esac
done

# ── Validate dependencies ────────────────────────────────────────────────────
for cmd in docker kind; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is not installed or not in PATH." >&2
    exit 1
  fi
done

if [[ ! -f "${DOCKERFILE_CONTEXT}/Dockerfile" ]]; then
  echo "Error: Dockerfile not found at ${DOCKERFILE_CONTEXT}/Dockerfile" >&2
  echo "Run this script from the repository root." >&2
  exit 1
fi

# ── Build ────────────────────────────────────────────────────────────────────
echo "==> Building image: ${IMAGE_TAG}"
echo "    (TMDB API key injected at runtime via Kubernetes Secret — not needed here)"

docker build \
  -t "${IMAGE_TAG}" \
  "${DOCKERFILE_CONTEXT}"

# ── Load into kind ───────────────────────────────────────────────────────────
echo "==> Loading image into kind cluster: ${CLUSTER_NAME}"

kind load docker-image "${IMAGE_TAG}" --name "${CLUSTER_NAME}"

echo "==> Done. Image '${IMAGE_TAG}' is available in cluster '${CLUSTER_NAME}'."
echo ""
echo "    Next: apply your API key secret to the cluster:"
echo "    kubectl create secret generic tmdb-api-key \\"
echo "      --from-literal=TMDB_V3_API_KEY=<your-key> \\"
echo "      -n netflix-clone --dry-run=client -o yaml | kubectl apply -f -"
