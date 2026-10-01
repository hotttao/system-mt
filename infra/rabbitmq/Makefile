SHELL := /usr/bin/env bash
NAMESPACE ?= infra

.PHONY: docker-up docker-down docker-reset k3s-up k3s-status k3s-down k3s-reset validate

docker-up:
	docker compose up --detach

docker-down:
	docker compose down

docker-reset:
	docker compose down --volumes

k3s-up:
	kubectl apply --kustomize k3s
	kubectl --namespace "$(NAMESPACE)" rollout status statefulset/rabbitmq --timeout=180s

k3s-status:
	kubectl --namespace "$(NAMESPACE)" get pods,services,persistentvolumeclaims

k3s-down:
	kubectl --namespace "$(NAMESPACE)" scale statefulset/rabbitmq --replicas=0

k3s-reset:
	kubectl delete --kustomize k3s

validate:
	docker compose config --quiet
	kubectl kustomize k3s >/dev/null
