#!/usr/bin/env bash
set -euo pipefail

CONTAINER="${OPENVIKING_CONTAINER:-openviking}"

if ! command -v jq >/dev/null 2>&1; then
  echo "错误：宿主机需要 jq。" >&2
  exit 1
fi

if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
  echo "错误：容器 $CONTAINER 不存在。" >&2
  exit 1
fi

mapfile -t DIRS < <(
  docker exec "$CONTAINER" ov ls viking://resources/ -o json 2>/dev/null |
    sed -n '/^{/,$p' |
    jq -r '.result[] | select(.isDir == true) | .uri'
)

if ((${#DIRS[@]} == 0)); then
  echo "viking://resources/ 下没有目录。"
  exit 0
fi

echo "将递归删除以下 ${#DIRS[@]} 个目录："
printf '  %s\n' "${DIRS[@]}"

if [[ "${1:-}" != "--yes" ]]; then
  read -r -p "确认删除？输入 DELETE 继续：" confirm
  [[ "$confirm" == "DELETE" ]] || { echo "已取消。"; exit 0; }
fi

for uri in "${DIRS[@]}"; do
  echo "删除 $uri"
  docker exec "$CONTAINER" ov rm "$uri" --recursive
done

echo "删除完成。"
