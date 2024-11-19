#!/bin/bash

# NATS 설치 스크립트
# 이 스크립트는 Helm을 사용하여 NATS를 설치하고 Kubernetes에서 LoadBalancer 서비스를 생성합니다.

set -e  # 스크립트 실행 중 오류 발생 시 종료
set -u  # 설정되지 않은 변수를 사용하면 오류 처리

# 1. NATS Helm Chart 저장소 추가 및 업데이트
echo "Adding NATS Helm repository..."
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update

# 2. 기본 값 파일 다운로드
#echo "Downloading default Helm values for NATS..."
#helm show values nats/nats > nats-values.yaml

# 3. NATS 설치
echo "Installing NATS with JetStream enabled..."
helm install nats nats/nats --namespace nats --create-namespace \
  --set config.jetstream.enabled=true \
  --set config.jetstream.fileStore.pvc.size=5Gi \
  --set config.jetstream.fileStore.pvc.storageClassName=local-path

# 4. Kubernetes LoadBalancer 서비스 생성
echo "Creating Kubernetes LoadBalancer service for NATS..."
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: nats
  namespace: nats
spec:
  type: LoadBalancer
  ports:
    - port: 4222
      targetPort: 4222
      protocol: TCP
  selector:
    app.kubernetes.io/instance: nats
    app.kubernetes.io/name: nats
EOF

echo "NATS installation and configuration completed successfully!"

