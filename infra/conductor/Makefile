SHELL := /usr/bin/env bash
IMAGE ?= conductoross/conductor:3.32.4
NAMESPACE ?= conductor

.PHONY: pull docker-up docker-down docker-reset k3s-up k3s-status k3s-down k3s-reset validate

pull:
	docker pull "$(IMAGE)"

docker-up: pull
	CONDUCTOR_IMAGE="$(IMAGE)" docker compose up --detach

docker-down:
	docker compose down

docker-reset:
	docker compose down --volumes

k3s-up:
	kubectl apply --kustomize k3s
	kubectl --namespace "$(NAMESPACE)" rollout status statefulset/postgres --timeout=180s
	kubectl --namespace "$(NAMESPACE)" rollout status deployment/conductor --timeout=300s

k3s-status:
	kubectl --namespace "$(NAMESPACE)" get pods,services,persistentvolumeclaims

k3s-down:
	kubectl --namespace "$(NAMESPACE)" scale deployment/conductor statefulset/postgres --replicas=0

k3s-reset:
	kubectl delete --kustomize k3s

validate:
	docker compose config --quiet
	kubectl kustomize k3s >/dev/null
