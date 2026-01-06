#!/bin/bash
# Question 7: RBAC - ServiceAccount, Role, and RoleBinding - Setup

set -e
echo "🔧 Setting up Question 7 environment..."

# Create namespace
kubectl create namespace secure-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up ALL RBAC resources (user must create these)
kubectl delete deployment secure-app -n secure-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete serviceaccount pod-reader-sa -n secure-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete role pod-reader-role -n secure-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete rolebinding pod-reader-binding -n secure-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create deployment using DEFAULT serviceaccount (will fail with Forbidden)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: secure-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
      - name: kubectl-container
        image: bitnami/kubectl:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            echo "Attempting to list pods..."
            kubectl get pods -n secure-ns 2>&1 || echo "Permission denied!"
            sleep 30
          done
EOF

# Wait for deployment
kubectl rollout status deployment/secure-app -n secure-ns --timeout=60s 2>/dev/null || true

echo ""
echo "✅ Namespace 'secure-ns' created"
echo "✅ Deployment 'secure-app' created (using default SA - shows Forbidden error)"
echo ""
echo "📍 Current ServiceAccounts (only default exists):"
kubectl get serviceaccounts -n secure-ns
echo ""
echo "📍 Current Roles (none exist):"
kubectl get roles -n secure-ns 2>/dev/null || echo "   No roles found"
echo ""
echo "📍 Deployment is failing with Forbidden error - check pod logs"
echo ""
echo "🎯 Environment ready!"
