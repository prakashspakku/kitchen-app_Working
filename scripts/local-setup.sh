#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="kitchen-app"

echo "==> Kitchen App local setup (Docker Desktop K8s)"

echo "==> Building Docker images (kitchen-api:local, kitchen-web:local)"
docker compose build api web-ui

echo "==> Creating namespace"
kubectl apply -f k8s/namespace.yaml

echo "==> Creating/updating MongoDB secret (mongodb-secret)"
kubectl create secret generic mongodb-secret \
  --from-literal=mongo-root-username=admin \
  --from-literal=mongo-root-password='Secret123!' \
  --from-literal=mongo-uri='mongodb://admin:Secret123!@mongodb-service.kitchen-app.svc.cluster.local:27017/kitchendb?authSource=admin' \
  --namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Creating/updating API config"
kubectl create configmap api-config \
  --from-literal=PORT=3000 \
  --namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Creating/updating API server override (api-server-override)"
kubectl create configmap api-server-override \
  --from-file=server.js=api/server.js \
  --namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Deploying MongoDB"
kubectl apply -f k8s/db/statefulset.yaml
kubectl rollout status statefulset/mongodb -n "$NAMESPACE" --timeout=180s

echo "==> Deploying API + Web UI"
kubectl apply -f k8s/api/deployment.yaml
kubectl apply -f k8s/web-ui/deployment.yaml
kubectl rollout status deployment/api-deployment -n "$NAMESPACE" --timeout=180s
kubectl rollout status deployment/web-ui-deployment -n "$NAMESPACE" --timeout=120s

echo
echo "==> Pods"
kubectl get pods -n "$NAMESPACE" -o wide

echo
echo "==> Services"
kubectl get svc -n "$NAMESPACE"

echo
echo "==> URLs (NodePort)"
echo "Web UI    : http://localhost:30080"
echo "API health: http://localhost:30000/health"
echo "API metrics: http://localhost:30000/metrics"

cat <<'EOF'

NOTE (Windows + Docker Desktop K8s):
- If NodePorts don't respond on localhost, use port-forward:

  kubectl port-forward -n kitchen-app svc/api-nodeport 30000:3000
  kubectl port-forward -n kitchen-app svc/web-ui-service 30080:80

Then open:
  http://localhost:30000/health
  http://localhost:30000/metrics
  http://localhost:30080

EOF