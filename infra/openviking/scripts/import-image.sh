#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/volcengine/openviking:v0.4.20}"
NAMESPACE="${NAMESPACE:-infra}"
TMP_TAR="$(mktemp --suffix=.tar openviking-image.XXXXXX)"
trap 'rm -f "$TMP_TAR"' EXIT

echo "Pulling $IMAGE"
docker pull "$IMAGE"
echo "Exporting image"
docker save -o "$TMP_TAR" "$IMAGE"
echo "Importing into k3s containerd"
sudo k3s ctr -n k8s.io images import "$TMP_TAR"
sudo k3s ctr -n k8s.io images inspect "$IMAGE" >/dev/null
echo "Image imported: $IMAGE"

if command -v kubectl >/dev/null 2>&1; then
  kubectl -n "$NAMESPACE" delete pod -l "app.kubernetes.io/name=openviking" --ignore-not-found
fi
