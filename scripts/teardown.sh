#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="kitchen-app"

echo "==> Tearing down Kitchen App resources"

echo "==> Deleting namespace (this deletes all app resources)"
kubectl delete namespace "$NAMESPACE" --ignore-not-found=true

echo "==> Done"