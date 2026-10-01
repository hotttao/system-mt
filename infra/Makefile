.PHONY: db
# 启动 mysql redis consul
db:
	@echo "Startging mysql redis consul"
	@docker-compose -f mysql/docker-compose.yaml up -d
	@docker-compose -f redis/docker-compose.yaml up -d
	@docker-compose -f consul/docker-compose.yaml up -d
	@echo "Database started."

.PHONY: nginx
# 启动 nginx
nginx:
	@echo "Startging nginx"
	@docker-compose -f nginx/docker-compose.yaml up -d
	@echo "Nginx started."

.PHONY: monitor
# 启动 prometheus 和 jaeger
monitor:
	@echo "Starting monitor"
	@docker-compose -f prometheus/docker-compose.yaml up -d
	@docker-compose -f jaeger/docker-compose.yaml up -d
	@echo "Monitor started."

.PHONY: plg
# 启动 loki 和 promtail
plg:
	@echo "Starting plg"
	@docker-compose -f plg/docker-compose.yaml up -d
	@echo "plg started."

.PHONY: nat
# 启动 nat
nat:
	@echo "Starting nat"
	@docker-compose -f nat/docker-compose.yaml up -d
	@echo "plg nat."

.PHONY: etcd
# 启动 etcd
etcd:
	@echo "Starting etcd"
	@docker-compose -f etcd/docker-compose.yaml up -d
	@echo "plg etcd."


.PHONY: start-all
# 启动所有容器
start-all:
	@docker-compose -f mysql/docker-compose.yaml up -d
	@docker-compose -f redis/docker-compose.yaml up -d
	@docker-compose -f consul/docker-compose.yaml up -d
	@docker-compose -f prometheus/docker-compose.yaml up -d
	@docker-compose -f jaeger/docker-compose.yaml up -d
	@docker-compose -f plg/docker-compose.yaml up -d
	#@docker-compose -f nat/docker-compose.yaml up -d
	#@docker-compose -f etcd/docker-compose.yaml up -d


.PHONY: stop-all
# 停止所有容器
stop-all:
	@docker-compose -f mysql/docker-compose.yaml down
	@docker-compose -f redis/docker-compose.yaml down
	@docker-compose -f consul/docker-compose.yaml down
	@docker-compose -f prometheus/docker-compose.yaml down
	@docker-compose -f jaeger/docker-compose.yaml down
	@docker-compose -f plg/docker-compose.yaml down
	@docker-compose -f nat/docker-compose.yaml down
	@docker-compose -f etcd/docker-compose.yaml down
	@docker-compose -f nginx/docker-compose.yaml down


.PHONY: dev
# 启动测试环境
dev: stop-all db monitor nginx
	@echo "Combined operations completed."

# show help
help:
	@echo ''
	@echo 'Usage:'
	@echo ' make [target]'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
	helpMessage = match(lastLine, /^# (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 2, RLENGTH); \
			printf "\033[36m%-22s\033[0m %s\n", helpCommand,helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help