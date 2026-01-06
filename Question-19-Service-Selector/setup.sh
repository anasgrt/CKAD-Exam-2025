#!/bin/bash
# Question 19: Service Selector Fix - Setup

set -e
echo "🔧 Setting up Question 19 environment..."

# Create namespace
kubectl create namespace svc-ns --dry-run=client -o yaml | kubectl apply -f -

# Clean up
kubectl delete deployment frontend-app -n svc-ns --ignore-not-found=true 2>/dev/null || true
kubectl delete service frontend-svc -n svc-ns --ignore-not-found=true 2>/dev/null || true
sleep 2

# Create Deployment with correct labels
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-app
  namespace: svc-ns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
      tier: web
  template:
    metadata:
      labels:
        app: frontend
        tier: web
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF

# Create Service with WRONG selector
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
  namespace: svc-ns
spec:
  selector:
    app: frontend-wrong
    tier: web
  ports:
  - port: 80
    targetPort: 80
EOF

sleep 3

echo ""
echo "✅ Namespace 'svc-ns' created"
echo "✅ Deployment 'frontend-app' created (3 replicas)"
echo "✅ Service 'frontend-svc' created (BROKEN - wrong selector)"
echo ""
echo "📍 Service selector:"
kubectl get svc frontend-svc -n svc-ns -o jsonpath='{.spec.selector}' && echo ""
echo ""
echo "📍 Pod labels:"
kubectl get pods -n svc-ns --show-labels
echo ""
echo "📍 Current endpoints:"
kubectl get endpoints frontend-svc -n svc-ns
echo ""
echo "🔴 The Service has no endpoints - fix the selector!"
echo ""
echo "🎯 Environment ready!"
