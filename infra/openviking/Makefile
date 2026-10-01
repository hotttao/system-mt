SHELL := /bin/bash

IMAGE ?= ghcr.io/volcengine/openviking:v0.4.20
NAMESPACE ?= infra
RELEASE ?= openviking
CHART ?= ../tmp/OpenViking/deploy/helm/openviking
K3S_VALUES ?= k3s/values.yaml

.PHONY: docker-up docker-down docker-logs k3s-install k3s-status import-image

docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f openviking

k3s-install:
	helm upgrade --install $(RELEASE) $(CHART) --namespace $(NAMESPACE) --create-namespace -f $(K3S_VALUES)
	kubectl apply -f k3s/nodeport-service.yaml

k3s-status:
	kubectl -n $(NAMESPACE) get deploy,pod,svc,pvc -l app.kubernetes.io/instance=$(RELEASE)

import-image:
	IMAGE=$(IMAGE) NAMESPACE=$(NAMESPACE) ./scripts/import-image.sh
