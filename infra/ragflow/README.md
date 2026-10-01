# RAGFlow 本地依赖

本目录管理本机 RAGFlow 使用的 Elasticsearch 服务。配置从
`/home/tao/code/github/ragflow/docker/docker-compose-base.yml` 迁移而来。

## 启动

```bash
cd /home/tao/code/github/infra/ragflow
cp .env.example .env # 仅在需要覆盖默认值时执行
docker compose up -d
# 或 make up
```

检查状态：

```bash
docker compose ps
curl http://localhost:1200
```

Elasticsearch 已启用认证，默认用户名为 `elastic`，密码由
`ELASTIC_PASSWORD` 设置。

## 停止

```bash
docker compose down
# 或 make down
```

数据继续保存在迁移前创建的外部 Docker volume `docker_esdata01` 中；执行
`docker compose down` 不会删除它。不要在未备份的情况下手动删除该 volume。
