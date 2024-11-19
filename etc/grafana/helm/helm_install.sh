#!/bin/bash

# Grafana 설치 스크립트

set -e  # 스크립트 실행 중 오류 발생 시 종료
set -u  # 설정되지 않은 변수를 사용하면 오류 처리

# 환경 변수 확인
# 스크립트 실행 전에 미리 설정된 환경 변수를 확인
if [ -z "${GRAFANA_ADMIN_USER+x}" ]; then
  echo "Error: GRAFANA_ADMIN_USER is not set. Please export it before running this script."
  exit 1
fi

if [ -z "${GRAFANA_ADMIN_PASSWORD+x}" ]; then
  echo "Error: GRAFANA_ADMIN_PASSWORD is not set. Please export it before running this script."
  exit 1
fi

echo "Environment variables for Grafana are set correctly."

# 1. Grafana Helm Chart 저장소 추가 및 업데이트
echo "Adding Grafana Helm repository..."
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. Grafana Helm Chart 값 오버라이드 파일 가져오기
echo "Fetching default values for Grafana from the Helm Chart..."
helm show values grafana/grafana > ./grafana-values.yaml

# 3. Grafana 설치
echo "Installing Grafana..."
helm install grafana grafana/grafana --namespace grafana --create-namespace \
  --set persistence.enabled=true \  # Grafana의 데이터가 저장될 영구 스토리지 활성화
  --set persistence.storageClassName=local-path \  # PVC의 스토리지 클래스를 로컬 스토리지로 설정
  --set persistence.size=50Gi \  # Grafana 데이터 크기 설정 (50Gi)
  --set adminUser=$GRAFANA_ADMIN_USER \  # 관리자 사용자 이름 설정
  --set adminPassword=$GRAFANA_ADMIN_PASSWORD \  # 관리자 비밀번호 설정
  --set service.type=LoadBalancer \  # Grafana 서비스 타입을 LoadBalancer로 설정 (외부에서 접근 가능)
  --set service.port=80 \  # Grafana 서비스의 외부 포트를 80으로 설정
  --set service.targetPort=3000 \  # Grafana의 내부 포트 (기본 포트 3000)

echo "Grafana installation completed successfully!"

# 4. Grafana의 관리자 비밀번호 확인
# 설치 후 생성된 secret에서 비밀번호를 확인합니다.
echo "Retrieving the admin password from the secret..."
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

