#!/bin/bash
# Question 3: Fix Broken Deployment - Setup

set -e
echo "🔧 Setting up Question 3 environment..."

# Create namespace
kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment backend-deployment -n staging --ignore-not-found=true 2>/dev/null || true
kubectl delete secret db-credentials db-credentials-old -n staging --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create the CORRECT secret
kubectl create secret generic db-credentials -n staging \
  --from-literal=DB_HOST=mysql.staging.svc \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=secretpass123

# Create the BROKEN deployment (references wrong secret name)
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment
  namespace: staging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: busybox
        command: ["sleep", "3600"]
        envFrom:
        - secretRef:
            name: db-credentials-old
EOF

echo ""
echo "✅ Namespace 'staging' created"
echo "✅ Secret 'db-credentials' created"
echo "✅ Deployment 'backend-deployment' created (BROKEN - wrong secret reference)"
echo ""
echo "📍 Available secrets:"
kubectl get secrets -n staging
echo ""
echo "📍 Pod status:"
sleep 3
kubectl get pods -n staging
echo ""
echo "🔴 The pods are failing - investigate and fix!"
echo ""
echo "🎯 Environment ready!"
