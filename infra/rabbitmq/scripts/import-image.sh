#!/usr/bin/env bash
set -euo pipefail

IMAGE="${RABBITMQ_IMAGE:-rabbitmq:3.13-management}"
NAMESPACE="${RABBITMQ_NAMESPACE:-infra}"
POD_SELECTOR="app.kubernetes.io/name=rabbitmq"
ARCHIVE="$(mktemp --suffix=.tar rabbitmq-image.XXXXXX)"

cleanup() {
  rm -f "$ARCHIVE"
}
trap cleanup EXIT

echo "Pulling Docker image: $IMAGE"
docker pull "$IMAGE"

echo "Saving image to temporary archive"
docker save --output "$ARCHIVE" "$IMAGE"

echo "Importing image into k3s containerd"
sudo k3s ctr -n k8s.io images import "$ARCHIVE"

echo "Verifying imported image"
sudo k3s ctr -n k8s.io images ls | grep -F "$IMAGE"

if command -v kubectl >/dev/null 2>&1; then
  echo "Restarting RabbitMQ Pod in namespace $NAMESPACE"
  kubectl --namespace "$NAMESPACE" delete pod \
    --selector "$POD_SELECTOR" \
    --ignore-not-found
fi

echo "RabbitMQ image import completed: $IMAGE"
