#!/bin/bash

# PostgreSQL 설치 스크립트

set -e  # 스크립트 실행 중 오류 발생 시 종료
set -u  # 설정되지 않은 변수를 사용하면 오류 처리

# 환경 변수 확인
# 스크립트 실행 전에 미리 설정된 환경 변수를 확인
if [ -z "${POSTGRES_PASSWORD+x}" ]; then
  echo "Error: POSTGRES_PASSWORD is not set. Please export it before running this script."
  exit 1
fi

if [ -z "${USERNAME+x}" ]; then
  echo "Error: USERNAME is not set. Please export it before running this script."
  exit 1
fi

if [ -z "${PASSWORD+x}" ]; then
  echo "Error: PASSWORD is not set. Please export it before running this script."
  exit 1
fi

if [ -z "${DATABASE+x}" ]; then
  echo "Error: DATABASE is not set. Please export it before running this script."
  exit 1
fi

echo "Environment variables are set correctly."

# 1. PostgreSQL Helm Chart 저장소 추가 및 업데이트
echo "Adding Bitnami Helm repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 2. PostgreSQL 설치
echo "Installing PostgreSQL..."
helm install postgresql bitnami/postgresql --namespace postgresql --create-namespace \
  --set global.postgresql.auth.postgresPassword=$POSTGRES_PASSWORD \  # PostgreSQL 기본 관리자 비밀번호 설정
  --set global.postgresql.auth.username=$USERNAME \  # 사용자 정의 데이터베이스 사용자 이름
  --set global.postgresql.auth.password=$PASSWORD \  # 사용자 정의 데이터베이스 사용자 비밀번호
  --set global.postgresql.auth.database=$DATABASE \  # 생성할 데이터베이스 이름
  --set primary.persistence.storageClass=local-path \  # PVC 스토리지 클래스 설정
  --set primary.persistence.size=200Gi \  # PostgreSQL 기본 저장소 크기
  --set primary.resources.requests.memory=512Mi \  # 기본 메모리 요청
  --set primary.resources.limits.memory=30000Mi \  # 메모리 제한 설정 (최대 30Gi)
  --set primary.service.type=LoadBalancer \  # PostgreSQL 서비스 타입을 LoadBalancer로 설정
  --set primary.service.port=5432  # PostgreSQL 기본 포트 설정

echo "PostgreSQL installation completed successfully!"
