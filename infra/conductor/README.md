# Conductor 本地部署

这里提供两种单机开发部署方式。两者默认使用官方稳定镜像
`conductoross/conductor:3.32.4`，只使用 PostgreSQL 16 作为持久化、任务队列、索引及分布式执行锁；
不依赖 Redis 或 Elasticsearch。

## 前置条件

- Docker Engine 与 Docker Compose v2
- k3s 模式还需要本机 k3s 和 `kubectl`
- 建议至少预留 2 GiB 内存；首次启动会下载容器镜像

需要切换镜像版本时，Docker Compose 模式可覆盖 `IMAGE`，例如：

```bash
make docker-up IMAGE=conductoross/conductor:3.32.4
```

## 模式一：Docker Compose

```bash
cd conductor
make docker-up
docker compose ps
```

启动完成后：

- UI: <http://192.168.2.41:5000>
- API: <http://192.168.2.41:8080/api>
- 健康检查: <http://192.168.2.41:8080/health>

停止服务但保留数据：

```bash
make docker-down
```

删除服务及 PostgreSQL 数据卷：

```bash
make docker-reset
```

端口冲突时，可通过环境变量覆盖宿主机端口：

```bash
CONDUCTOR_API_PORT=18080 CONDUCTOR_UI_PORT=15000 make docker-up
```

监听地址默认为 `192.168.2.41`，也可以按本机实际局域网地址覆盖：

```bash
CONDUCTOR_BIND_ADDRESS=192.168.2.100 make docker-up
```

## 模式二：本机 k3s

`make k3s-up` 会部署全部资源，k3s 会直接拉取固定版本的官方镜像：

```bash
cd conductor
make k3s-up
make k3s-status
```

默认使用 `conductor` namespace 和 k3s 的默认 StorageClass。访问地址为：

- UI: <http://localhost:30500>
- API: <http://localhost:30080/api>
- 健康检查: <http://localhost:30080/health>

如果本机无法直接访问 NodePort，可使用端口转发：

```bash
kubectl -n conductor port-forward service/conductor 8080:8080 5000:5000
```

暂停工作负载并保留 PVC 数据：

```bash
make k3s-down
```

重新执行 `make k3s-up` 会恢复副本数。彻底删除资源和 PVC 数据：

```bash
make k3s-reset
```

查看故障信息：

```bash
kubectl -n conductor get pods
kubectl -n conductor logs deployment/conductor --tail=200
kubectl -n conductor describe pod -l app.kubernetes.io/name=conductor
```

如需为 k3s 切换版本，修改 `k3s/conductor.yaml` 中的镜像标签。

## Elasticsearch 与 PostgreSQL 索引说明

Elasticsearch 在 Conductor 中主要承担执行记录检索索引的角色，并不是工作流状态的主数据库。它主要检索：

- Workflow 执行摘要：`workflowId`、`workflowType`、状态、关联 ID、时间、父 Workflow 和 JSON 数据
- Task 执行摘要：`taskId`、Task 类型、Task 定义名、状态、时间和 JSON 数据
- Task execution logs
- UI 中的执行历史、状态过滤、时间范围过滤、全文搜索和 JSON 条件查询

Workflow 定义、Task 定义和实际执行数据仍然由主存储负责保存。

当前部署使用 PostgreSQL 索引模式：

```properties
conductor.indexing.enabled=true
conductor.indexing.type=postgres
conductor.elasticsearch.version=0
```

Conductor 会将检索摘要写入 PostgreSQL 的 `workflow_index`、`task_index` 和
`task_execution_logs` 表，并使用普通索引、JSONB GIN 索引和 PostgreSQL 全文检索完成查询。

PostgreSQL 不是 Elasticsearch 的完全等价替代。当前源码中 Workflow/Task 摘要查询支持 PostgreSQL，
但旧版 `searchWorkflows()`、`searchTasks()` 接口在 PostgreSQL DAO 中不支持，部分 V2 搜索、跨 Workflow
查询和按 correlation ID 查询路径可能依赖这些旧接口。

因此 PostgreSQL-only 模式适合本地开发和中小规模部署，尤其适合按状态、Workflow 类型、时间和关联 ID
查询的场景。如果执行记录规模较大，或需要完整的高级执行历史搜索、复杂全文检索和高并发检索，建议使用
Elasticsearch。
