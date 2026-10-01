# OpenViking 部署

本目录提供 OpenViking 的本地 Docker 和 k3s 部署入口，配置基于
`tmp/OpenViking/deploy/helm/openviking` 官方 Helm chart。当前固定使用稳定镜像
`ghcr.io/volcengine/openviking:v0.4.20`，避免 `latest` 漂移。

## Docker

```bash
cd openviking
cp .env.example .env       # 默认监听 192.168.2.41:1933
docker compose pull
docker compose up -d
docker compose ps
curl http://192.168.2.41:1933/health
```

数据保存在 Docker volume `openviking_openviking-data` 中。停止服务：

```bash
docker compose down
```

## k3s

k3s 使用 `infra` namespace、官方 chart 和 `local-path` PVC，服务通过
`192.168.2.41:31933` 暴露。若节点不能访问 GHCR，先执行镜像导入脚本：

```bash
cd openviking
./scripts/import-image.sh
make k3s-install
make k3s-status
curl http://192.168.2.41:31933/health
```

也可以直接拉取镜像后安装：

```bash
helm upgrade --install openviking ../tmp/OpenViking/deploy/helm/openviking \
  --namespace infra --create-namespace -f k3s/values.yaml
```

OpenViking 使用本地 RocksDB/工作区持久化，单副本是必要条件；不要把副本数扩展到
多个 Pod 共享同一个 PVC。向量模型和 VLM 的 API key 按官方 chart 的 values 配置，
未配置时服务可以启动，但实际索引/解析操作需要补充对应模型配置。

卸载 k3s release：

```bash
helm uninstall openviking -n infra
```

## 清空 resources

删除 `viking://resources/` 下所有一级目录及其内容（不会删除根路径）：

```bash
./scripts/clear-resources.sh
# 或跳过确认
./scripts/clear-resources.sh --yes
```
