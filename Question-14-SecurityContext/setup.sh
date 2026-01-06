#!/bin/bash
# Question 14: SecurityContext - Edit Existing Deployment - Setup

set -e
echo "🔧 Setting up Question 14 environment..."

# Create namespace
kubectl create namespace secure-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment secure-app -n secure-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create deployment WITHOUT security context and PAUSED
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: secure-ns
spec:
  replicas: 2
  paused: true
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
      - name: app
        image: nginx:1.21
        ports:
        - containerPort: 80
EOF

echo ""
echo "✅ Namespace 'secure-ns' created"
echo "✅ Deployment 'secure-app' created (PAUSED, no securityContext)"
echo ""
echo "📍 Deployment status:"
kubectl get deployment secure-app -n secure-ns
echo ""
echo "📍 Note: Deployment is PAUSED - needs security hardening then resume"
echo ""
echo "🎯 Environment ready!"
