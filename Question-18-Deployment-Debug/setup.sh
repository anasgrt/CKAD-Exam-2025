#!/bin/bash
# Question 18: Fix Deployment - Container Name & Image + Resume Rollout - Setup

set -e
echo "🔧 Setting up Question 18 environment..."

# Create namespace
kubectl create namespace api-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment api-server -n api-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create deployment with WRONG container name and image, and PAUSED
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  namespace: api-ns
spec:
  replicas: 2
  paused: true
  selector:
    matchLabels:
      app: api-server
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: wrong-name
        image: nginx:wrong
        ports:
        - containerPort: 80
EOF

echo ""
echo "✅ Namespace 'api-ns' created"
echo "✅ Deployment 'api-server' created (PAUSED, wrong container name and image)"
echo ""
echo "📍 Deployment status:"
kubectl get deployment api-server -n api-ns
echo ""
echo "📍 Note: Deployment is PAUSED - needs container name and image fix, then resume"
echo ""
echo "🎯 Environment ready!"
