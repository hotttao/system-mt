# RabbitMQ 本地部署

提供 Docker Compose 和本机 k3s 两种部署方式，默认使用 `rabbitmq:3.13-management`，
并将 RabbitMQ 数据保存到持久卷。

默认开发账号为 `rabbit/rabbit`。生产环境请通过环境变量覆盖密码，避免使用默认凭据。

## Docker Compose

```bash
cd rabbitmq
make docker-up
docker compose ps
```

访问地址：

- AMQP：`192.168.2.41:5672`
- 管理界面：<http://192.168.2.41:15672>

停止服务但保留数据：

```bash
make docker-down
```

删除容器和数据卷：

```bash
make docker-reset
```

可以覆盖监听地址、端口和凭据：

```bash
RABBITMQ_BIND_ADDRESS=192.168.2.100 \
RABBITMQ_DEFAULT_USER=admin \
RABBITMQ_DEFAULT_PASS='change-me' \
make docker-up
```

## 本机 k3s

资源统一部署到 `infra` namespace。

如果 k3s 节点无法直接拉取镜像，可以手动导入：

```bash
cd rabbitmq
./scripts/import-image.sh
```

脚本需要当前用户具备 Docker 权限和免密 `sudo k3s ctr` 权限；也可以覆盖镜像或 namespace：

```bash
RABBITMQ_IMAGE=rabbitmq:3.13-management RABBITMQ_NAMESPACE=infra \
  ./scripts/import-image.sh
```

```bash
make k3s-up
make k3s-status
```

默认 NodePort：

- AMQP：`192.168.2.41:30673`
- 管理界面：<http://192.168.2.41:31673>

暂停工作负载并保留数据：

```bash
make k3s-down
```

删除资源和 PVC：

```bash
make k3s-reset
```

## RabbitMQ 连接示例

```text
amqp://rabbit:rabbit@192.168.2.41:5672/
```
