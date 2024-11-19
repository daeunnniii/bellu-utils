#!/bin/bash

# ClickHouse 설치 스크립트

set -e  # 스크립트 실행 중 오류 발생 시 종료
set -u  # 설정되지 않은 변수를 사용하면 오류 처리

# 1. ClickHouse Helm Chart 저장소 추가 및 업데이트
echo "Adding ClickHouse Helm repository..."
helm repo add clickhouse https://helm.clickhouse.com/
helm repo update

# 2. ClickHouse 설치
# 사용자 이름과 비밀번호를 환경 변수로 설정해야함.
# {id}와 {passwd}를 실제 값으로 대체하거나 이 스크립트 실행 전에 설정.
# 예: export CLICKHOUSE_USER="admin" CLICKHOUSE_PASS="strongpassword"
if [[ -z "${CLICKHOUSE_USER:-}" || -z "${CLICKHOUSE_PASS:-}" ]]; then
  echo "Error: CLICKHOUSE_USER and CLICKHOUSE_PASS environment variables must be set."
  exit 1
fi

echo "Installing ClickHouse with customized configuration..."
helm install clickhouse bitnami/clickhouse --namespace clickhouse --create-namespace \
  --set replicaCount=2 \
  --set auth.username="$CLICKHOUSE_USER" \
  --set auth.password="$CLICKHOUSE_PASS" \
  --set resources.requests.memory=2Gi \
  --set resources.requests.cpu=500m \
  --set resources.limits.memory=10Gi \
  --set resources.limits.cpu=4 \
  --set persistence.storageClass=nfs-client \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --set service.type=LoadBalancer \
  --set service.ports.http=8123 \
  --set service.ports.tcp=9000

echo "ClickHouse installation and configuration completed successfully!"

